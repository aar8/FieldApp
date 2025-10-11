import type { Database, RunResult } from "better-sqlite3";
import { TypedError } from "../types/errors.js";
import { withDatabase } from "../utils/database.js";
import { uuidv4 } from "../utils/uuid.js";

type SupportedObjectType = "customers" | "jobs" | "job_events" | "attachments";

export interface BatchChange {
  readonly id?: string;
  readonly client_id?: string;
  readonly deleted?: boolean;
  readonly version?: number;
  readonly [key: string]: unknown;
}

export type BatchStatus = "inserted" | "updated" | "deleted" | "conflict";

export interface BatchResult {
  readonly id: string;
  readonly status: BatchStatus;
  readonly client_id?: string;
  readonly record?: Record<string, unknown>;
  readonly deleted?: true;
}

interface TableAdapter {
  readonly tableName: string;
  readonly insert: (db: Database, tenantId: string, record: Record<string, unknown>) => void;
  readonly get: (db: Database, tenantId: string, id: string) => Record<string, unknown> | undefined;
  readonly delete: (db: Database, tenantId: string, id: string) => RunResult;
}

type UpdateStatement = {
  readonly sql: string;
  readonly parameters: Record<string, unknown>;
};

const TABLE_REGISTRY: Record<SupportedObjectType, TableAdapter> = {
  customers: createTableAdapter("customers"),
  jobs: createTableAdapter("jobs"),
  job_events: createTableAdapter("job_events"),
  attachments: createTableAdapter("attachments"),
};

let syncEventsReady = false;

const ensureForeignKeys = (db: Database): void => {
  db.pragma("foreign_keys = ON");
};

const ensureSyncEventsTable = (db: Database): void => {
  if (syncEventsReady) {
    return;
  }

  db.exec(`
    CREATE TABLE IF NOT EXISTS sync_events (
      id TEXT PRIMARY KEY,
      tenant_id TEXT NOT NULL,
      object_type TEXT NOT NULL,
      record_id TEXT NOT NULL,
      event_type TEXT NOT NULL,
      payload TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE (tenant_id, id)
    );
  `);

  syncEventsReady = true;
};

export const updateBatch = async (
  objectType: string,
  tenantId: string,
  changes: ReadonlyArray<BatchChange>
): Promise<BatchResult[]> => {
  if (!isSupportedObject(objectType)) {
    throw new TypedError(`Unsupported object type: ${objectType}`, {
      status: 400,
      code: "validation_error",
    });
  }

  if (!Array.isArray(changes)) {
    throw new TypedError("Changes payload must be an array", {
      status: 400,
      code: "validation_error",
    });
  }

  return withDatabase((db) => {
    ensureForeignKeys(db);
    ensureSyncEventsTable(db);

    const adapter = TABLE_REGISTRY[objectType];
    const results: BatchResult[] = [];

    const transactional = db.transaction((items: ReadonlyArray<BatchChange>) => {
      for (const rawChange of items) {
        const change = { ...rawChange };
        const changeId = typeof change.id === "string" ? change.id.trim() : undefined;

        if (!changeId && !change.deleted) {
          throw new TypedError("Missing change id", {
            status: 400,
            code: "validation_error",
          });
        }

        if (change.deleted === true) {
          if (!changeId) {
            throw new TypedError("Missing id for delete operation", {
              status: 400,
              code: "validation_error",
            });
          }

          const deletion = adapter.delete(db, tenantId, changeId);
          if (deletion.changes === 0) {
            recordConflict(db, tenantId, objectType, changeId, "delete_conflict", change);
            results.push({
              id: changeId,
              status: "conflict",
            });
          } else {
            results.push({
              id: changeId,
              status: "deleted",
              deleted: true,
            });
          }
          continue;
        }

        if (!changeId) {
          throw new TypedError("Change id must be provided", {
            status: 400,
            code: "validation_error",
          });
        }

        if (isClientId(changeId)) {
          const serverId = uuidv4();
          const now = new Date().toISOString();
          const record = buildInsertRecord(objectType, tenantId, change, now, serverId);

          adapter.insert(db, tenantId, record);

          const persisted = adapter.get(db, tenantId, serverId) ?? record;
          results.push({
            id: serverId,
            client_id: changeId,
            status: "inserted",
            record: persisted,
          });
          continue;
        }

        const updatePayload = sanitizeChange(changeId, change, objectType);
        const timestamp = new Date().toISOString();
        const { sql, parameters } = buildUpdateStatement(
          adapter.tableName,
          tenantId,
          updatePayload,
          timestamp
        );
        const outcome = db.prepare(sql).run(parameters);

        if (outcome.changes === 0) {
          recordConflict(db, tenantId, objectType, changeId, "update_conflict", change);
          results.push({
            id: changeId,
            status: "conflict",
          });
          continue;
        }

        const persisted = adapter.get(db, tenantId, changeId);
        results.push({
          id: changeId,
          status: "updated",
          record: persisted ?? { ...updatePayload, tenant_id: tenantId },
        });
      }
    });

    transactional(changes);

    return results;
  });
};

const buildInsertRecord = (
  objectType: string,
  tenantId: string,
  change: BatchChange,
  timestamp: string,
  serverId: string
): Record<string, unknown> => {
  const record = { ...change } as Record<string, unknown>;
  delete record.client_id;
  delete record.deleted;

  record.id = serverId;
  record.tenant_id = tenantId;
  record.object_type = typeof change.object_type === "string" ? change.object_type : objectType;
  record.status = typeof change.status === "string" ? change.status : "active";
  record.version = typeof change.version === "number" ? change.version : 0;
  record.created_at = timestamp;
  record.updated_at = timestamp;

  return record;
};

const sanitizeChange = (
  id: string,
  change: BatchChange,
  objectType: string
): Record<string, unknown> => {
  const payload: Record<string, unknown> = { ...change };
  delete payload.id;
  delete payload.client_id;
  delete payload.deleted;

  if (payload.object_type === undefined) {
    payload.object_type = objectType;
  }

  return { id, ...payload };
};

export const buildUpdateStatement = (
  tableName: string,
  tenantId: string,
  payload: Record<string, unknown>,
  updatedAt: string
): UpdateStatement => {
  const exclude = new Set(["id", "tenant_id", "created_at", "updated_at", "version"]);
  const keys = Object.keys(payload).filter((key) => !exclude.has(key));

  const assignments: string[] = keys.map((key) => `${key} = COALESCE(@${key}, ${key})`);
  assignments.push("version = version + 1");
  assignments.push("updated_at = @updated_at");

  const parameters: Record<string, unknown> = {
    id: payload.id,
    tenant_id: tenantId,
    updated_at: updatedAt,
  };

  for (const key of keys) {
    parameters[key] = payload[key];
  }

  const sql = `UPDATE ${tableName} SET ${assignments.join(", ")} WHERE tenant_id = @tenant_id AND id = @id`;
  return { sql, parameters };
};

const recordConflict = (
  db: Database,
  tenantId: string,
  objectType: string,
  recordId: string,
  eventType: string,
  payload: BatchChange
): void => {
  const statement = db.prepare(`
    INSERT INTO sync_events (id, tenant_id, object_type, record_id, event_type, payload)
    VALUES (@id, @tenant_id, @object_type, @record_id, @event_type, @payload)
  `);

  statement.run({
    id: uuidv4(),
    tenant_id: tenantId,
    object_type: objectType,
    record_id: recordId,
    event_type: eventType,
    payload: JSON.stringify(payload),
  });
};

const createTableAdapter = (tableName: SupportedObjectType): TableAdapter => {
  const insert = (db: Database, tenantId: string, record: Record<string, unknown>): void => {
    const payload = { ...record, tenant_id: tenantId };
    const columns = Object.keys(payload);
    if (columns.length === 0) {
      throw new TypedError(`Insert payload for ${tableName} is empty`, {
        status: 400,
        code: "validation_error",
      });
    }

    const placeholders = columns.map((column) => `@${column}`);
    const sql = `INSERT INTO ${tableName} (${columns.join(", ")}) VALUES (${placeholders.join(", ")})`;
    db.prepare(sql).run(payload);
  };

  const get = (
    db: Database,
    tenantId: string,
    id: string
  ): Record<string, unknown> | undefined => {
    const row = db
      .prepare(`SELECT * FROM ${tableName} WHERE tenant_id = ? AND id = ?`)
      .get(tenantId, id) as Record<string, unknown> | undefined;
    return row;
  };

  const remove = (db: Database, tenantId: string, id: string): RunResult => {
    return db.prepare(`DELETE FROM ${tableName} WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
  };

  return {
    tableName,
    insert,
    get,
    delete: remove,
  };
};

const isSupportedObject = (value: string): value is SupportedObjectType => {
  return value === "customers" || value === "jobs" || value === "job_events" || value === "attachments";
};

const isClientId = (value: string): boolean => value.startsWith("client-");
