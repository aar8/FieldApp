import type { Database } from "better-sqlite3";
import type { Request, Router } from "express";
import {
  createAttachment,
  deleteAttachment,
  getAttachment,
  updateAttachment,
} from "../db/attachments.js";
import {
  createCustomer,
  deleteCustomer,
  getCustomer,
  updateCustomer,
} from "../db/customers.js";
import {
  createJobEvent,
  deleteJobEvent,
  getJobEvent,
  updateJobEvent,
} from "../db/jobEvents.js";
import { createJob, deleteJob, getJob, updateJob } from "../db/jobs.js";
import { createUser, deleteUser, getUser, updateUser } from "../db/users.js";
import { TypedError } from "../types/errors.js";
import type { SyncConflict, SyncPayloadSchema, SyncResult } from "../types/sync.js";
import { syncPayloadSchema } from "../types/sync.js";
import { withDatabase } from "../utils/database.js";

type TableName = SyncPayloadSchema["changes"][number]["table"];
type SyncChange = SyncPayloadSchema["changes"][number];

type ChangeRecord = Record<string, unknown>;

interface VersionedEntity {
  readonly version: number;
}

interface EntityAdapter<T extends VersionedEntity> {
  get: (db: Database, tenantId: string, id: string) => T | undefined;
  insert: (db: Database, tenantId: string, change: SyncChange, current: T | undefined) => boolean;
  update: (db: Database, tenantId: string, change: SyncChange, current: T | undefined) => boolean;
  delete: (db: Database, tenantId: string, id: string) => boolean;
}

const ensureRecord = (data: unknown, entity: string): ChangeRecord => {
  if (data && typeof data === "object" && !Array.isArray(data)) {
    return data as ChangeRecord;
  }

  throw new TypedError(`Invalid payload for ${entity}`, {
    status: 400,
    code: "validation_error",
  });
};

const requireString = (record: ChangeRecord, key: string, entity: string): string => {
  const value = record[key];
  if (typeof value === "string" && value.length > 0) {
    return value;
  }

  throw new TypedError(`Missing or invalid ${entity}.${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const optionalString = (record: ChangeRecord, key: string): string | undefined => {
  if (!(key in record)) {
    return undefined;
  }

  const value = record[key];
  if (typeof value === "string") {
    return value;
  }

  if (value === null || value === undefined) {
    return undefined;
  }

  throw new TypedError(`Invalid value for ${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const optionalNullableString = (record: ChangeRecord, key: string): string | null | undefined => {
  if (!(key in record)) {
    return undefined;
  }

  const value = record[key];
  if (value === null) {
    return null;
  }

  if (typeof value === "string") {
    return value;
  }

  throw new TypedError(`Invalid value for ${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const requireNumber = (record: ChangeRecord, key: string, entity: string): number => {
  const value = record[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  throw new TypedError(`Missing or invalid ${entity}.${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const optionalNumber = (record: ChangeRecord, key: string): number | undefined => {
  if (!(key in record)) {
    return undefined;
  }

  const value = record[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }

  if (value === null || value === undefined) {
    return undefined;
  }

  throw new TypedError(`Invalid value for ${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const optionalPayload = (record: ChangeRecord, key: string): string | null | undefined => {
  if (!(key in record)) {
    return undefined;
  }

  const value = record[key];
  if (value === null) {
    return null;
  }

  if (typeof value === "string") {
    return value;
  }

  if (typeof value === "object") {
    return JSON.stringify(value);
  }

  throw new TypedError(`Invalid payload for ${key}`, {
    status: 400,
    code: "validation_error",
  });
};

const buildUserCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  email: requireString(record, "email", "user"),
  displayName: requireString(record, "displayName", "user"),
  role: optionalString(record, "role"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  createdAt: optionalString(record, "createdAt"),
  updatedAt: optionalString(record, "updatedAt"),
});

const buildUserUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  email: optionalString(record, "email"),
  displayName: optionalString(record, "displayName"),
  role: optionalString(record, "role"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  updatedAt: optionalString(record, "updatedAt"),
});

const buildCustomerCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  name: requireString(record, "name", "customer"),
  contactEmail: optionalNullableString(record, "contactEmail"),
  phone: optionalNullableString(record, "phone"),
  location: optionalNullableString(record, "location"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  createdAt: optionalString(record, "createdAt"),
  updatedAt: optionalString(record, "updatedAt"),
});

const buildCustomerUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  name: optionalString(record, "name"),
  contactEmail: optionalNullableString(record, "contactEmail"),
  phone: optionalNullableString(record, "phone"),
  location: optionalNullableString(record, "location"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  updatedAt: optionalString(record, "updatedAt"),
});

const buildJobCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  customerId: requireString(record, "customerId", "job"),
  assignedTo: optionalNullableString(record, "assignedTo"),
  status: optionalString(record, "status"),
  scheduledStart: optionalNullableString(record, "scheduledStart"),
  scheduledEnd: optionalNullableString(record, "scheduledEnd"),
  notes: optionalNullableString(record, "notes"),
  objectType: optionalString(record, "objectType"),
  version: change.version,
  createdAt: optionalString(record, "createdAt"),
  updatedAt: optionalString(record, "updatedAt"),
});

const buildJobUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  customerId: optionalString(record, "customerId"),
  assignedTo: optionalNullableString(record, "assignedTo"),
  status: optionalString(record, "status"),
  scheduledStart: optionalNullableString(record, "scheduledStart"),
  scheduledEnd: optionalNullableString(record, "scheduledEnd"),
  notes: optionalNullableString(record, "notes"),
  objectType: optionalString(record, "objectType"),
  version: change.version,
  updatedAt: optionalString(record, "updatedAt"),
});

const buildJobEventCreateInput = (
  tenantId: string,
  change: SyncChange,
  record: ChangeRecord
) => ({
  id: change.primaryKey,
  tenantId,
  jobId: requireString(record, "jobId", "jobEvent"),
  eventType: requireString(record, "eventType", "jobEvent"),
  payload: optionalPayload(record, "payload"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  createdAt: optionalString(record, "createdAt"),
  updatedAt: optionalString(record, "updatedAt"),
});

const buildJobEventUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  eventType: optionalString(record, "eventType"),
  payload: optionalPayload(record, "payload"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  updatedAt: optionalString(record, "updatedAt"),
});

const buildAttachmentCreateInput = (
  tenantId: string,
  change: SyncChange,
  record: ChangeRecord
) => ({
  id: change.primaryKey,
  tenantId,
  jobId: optionalNullableString(record, "jobId"),
  customerId: optionalNullableString(record, "customerId"),
  fileName: requireString(record, "fileName", "attachment"),
  fileType: requireString(record, "fileType", "attachment"),
  fileSize: requireNumber(record, "fileSize", "attachment"),
  checksum: optionalNullableString(record, "checksum"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  createdAt: optionalString(record, "createdAt"),
  updatedAt: optionalString(record, "updatedAt"),
});

const buildAttachmentUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  jobId: optionalNullableString(record, "jobId"),
  customerId: optionalNullableString(record, "customerId"),
  fileName: optionalString(record, "fileName"),
  fileType: optionalString(record, "fileType"),
  fileSize: optionalNumber(record, "fileSize"),
  checksum: optionalNullableString(record, "checksum"),
  objectType: optionalString(record, "objectType"),
  status: optionalString(record, "status"),
  version: change.version,
  updatedAt: optionalString(record, "updatedAt"),
});

const userAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getUser(db, tenantId, id) ?? undefined,
  insert: (db, tenantId, change, current) => {
    const record = ensureRecord(change.data, "user");
    if (current) {
      const updateInput = buildUserUpdateInput(change, record);
      return Boolean(updateUser(db, tenantId, change.primaryKey, updateInput));
    }

    const createInput = buildUserCreateInput(tenantId, change, record);
    createUser(db, createInput);
    return true;
  },
  update: (db, tenantId, change) => {
    const record = ensureRecord(change.data, "user");
    const updateInput = buildUserUpdateInput(change, record);

    const updated = updateUser(db, tenantId, change.primaryKey, updateInput);
    return Boolean(updated);
  },
  delete: (db, tenantId, id) => deleteUser(db, tenantId, id),
};

const customerAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getCustomer(db, tenantId, id) ?? undefined,
  insert: (db, tenantId, change, current) => {
    const record = ensureRecord(change.data, "customer");
    if (current) {
      const updateInput = buildCustomerUpdateInput(change, record);
      return Boolean(updateCustomer(db, tenantId, change.primaryKey, updateInput));
    }

    const createInput = buildCustomerCreateInput(tenantId, change, record);
    createCustomer(db, createInput);
    return true;
  },
  update: (db, tenantId, change) => {
    const record = ensureRecord(change.data, "customer");
    const updateInput = buildCustomerUpdateInput(change, record);

    const updated = updateCustomer(db, tenantId, change.primaryKey, updateInput);
    return Boolean(updated);
  },
  delete: (db, tenantId, id) => deleteCustomer(db, tenantId, id),
};

const jobAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getJob(db, tenantId, id) ?? undefined,
  insert: (db, tenantId, change, current) => {
    const record = ensureRecord(change.data, "job");
    if (current) {
      const updateInput = buildJobUpdateInput(change, record);
      return Boolean(updateJob(db, tenantId, change.primaryKey, updateInput));
    }

    const createInput = buildJobCreateInput(tenantId, change, record);
    createJob(db, createInput);
    return true;
  },
  update: (db, tenantId, change) => {
    const record = ensureRecord(change.data, "job");
    const updateInput = buildJobUpdateInput(change, record);

    const updated = updateJob(db, tenantId, change.primaryKey, updateInput);
    return Boolean(updated);
  },
  delete: (db, tenantId, id) => deleteJob(db, tenantId, id),
};

const jobEventAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getJobEvent(db, tenantId, id) ?? undefined,
  insert: (db, tenantId, change, current) => {
    const record = ensureRecord(change.data, "jobEvent");
    if (current) {
      const updateInput = buildJobEventUpdateInput(change, record);
      return Boolean(updateJobEvent(db, tenantId, change.primaryKey, updateInput));
    }

    const createInput = buildJobEventCreateInput(tenantId, change, record);
    createJobEvent(db, createInput);
    return true;
  },
  update: (db, tenantId, change) => {
    const record = ensureRecord(change.data, "jobEvent");
    const updateInput = buildJobEventUpdateInput(change, record);

    const updated = updateJobEvent(db, tenantId, change.primaryKey, updateInput);
    return Boolean(updated);
  },
  delete: (db, tenantId, id) => deleteJobEvent(db, tenantId, id),
};

const attachmentAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getAttachment(db, tenantId, id) ?? undefined,
  insert: (db, tenantId, change, current) => {
    const record = ensureRecord(change.data, "attachment");
    if (current) {
      const updateInput = buildAttachmentUpdateInput(change, record);
      return Boolean(updateAttachment(db, tenantId, change.primaryKey, updateInput));
    }

    const createInput = buildAttachmentCreateInput(tenantId, change, record);
    createAttachment(db, createInput);
    return true;
  },
  update: (db, tenantId, change) => {
    const record = ensureRecord(change.data, "attachment");
    const updateInput = buildAttachmentUpdateInput(change, record);

    const updated = updateAttachment(db, tenantId, change.primaryKey, updateInput);
    return Boolean(updated);
  },
  delete: (db, tenantId, id) => deleteAttachment(db, tenantId, id),
};

const entityAdapters: Record<TableName, EntityAdapter<VersionedEntity>> = {
  users: userAdapter,
  customers: customerAdapter,
  jobs: jobAdapter,
  job_events: jobEventAdapter,
  attachments: attachmentAdapter,
};

const applyChange = (
  change: SyncChange,
  conflicts: SyncConflict[],
  db: Database
): boolean => {
  const adapter = entityAdapters[change.table];
  if (!adapter) {
    throw new TypedError(`Unsupported table ${change.table}`, {
      status: 400,
      code: "validation_error",
    });
  }

  const current = adapter.get(db, change.primaryKey);
  if (current && change.version < current.version) {
    conflicts.push({
      entity: change.table,
      entityId: change.primaryKey,
      reason: `Incoming version ${change.version} is behind stored version ${current.version}`,
    });
    return false;
  }

  switch (change.action) {
    case "insert": {
      return adapter.insert(db, change, current);
    }
    case "update": {
      if (!current) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Update ignored because target row was not found",
        });
        return false;
      }

      const updated = adapter.update(db, change, current);
      if (!updated) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Update ignored because target row was not found",
        });
      }
      return updated;
    }
    case "delete": {
      const deleted = adapter.delete(db, change.primaryKey);
      if (!deleted) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Delete ignored because target row was not found",
        });
      }
      return deleted;
    }
    default: {
      throw new TypedError(`Unsupported action ${change.action}`, {
        status: 400,
        code: "validation_error",
      });
    }
  }
};

export const registerSyncRoute = (router: Router): void => {
  router.post("/sync", async (req, res, next) => {
    try {
      const parsed = syncPayloadSchema.safeParse(req.body);
      if (!parsed.success) {
        throw new TypedError("Invalid sync payload", {
          status: 400,
          code: "validation_error",
          details: parsed.error.flatten(),
        });
      }

      const { changes } = parsed.data;
      const conflicts: SyncConflict[] = [];
      let appliedChanges = 0;

      await withDatabase((db) => {
        const transactional = db.transaction((batchedChanges: typeof changes) => {
          for (const change of batchedChanges) {
            const applied = applyChange(change, conflicts, db);
            if (applied) {
              appliedChanges += 1;
            }
          }
        });

        transactional(changes);

        return true;
      });

      const payload: SyncResult = {
        summary: {
          appliedChanges,
          pendingChanges: conflicts.length,
          lastSyncedAt: new Date().toISOString(),
        },
        conflicts,
      };

      res.json(payload);
    } catch (error) {
      next(error);
    }
  });
};
