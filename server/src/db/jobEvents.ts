import type { Database } from "better-sqlite3";

export interface JobEvent {
  readonly id: string;
  readonly tenantId: string;
  readonly jobId: string;
  readonly eventType: string;
  readonly payload: string | null;
  readonly objectType: string;
  readonly status: string;
  readonly version: number;
  readonly createdAt: string;
  readonly updatedAt: string;
}

export interface JobEventCreateInput {
  readonly id: string;
  readonly tenantId: string;
  readonly jobId: string;
  readonly eventType: string;
  readonly payload?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly createdAt?: string;
  readonly updatedAt?: string;
}

export interface JobEventUpdateInput {
  readonly eventType?: string;
  readonly payload?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly updatedAt?: string;
}

const rowToJobEvent = (row: any): JobEvent => ({
  id: row.id,
  tenantId: row.tenantId,
  jobId: row.jobId,
  eventType: row.eventType,
  payload: row.payload ?? null,
  objectType: row.objectType,
  status: row.status,
  version: row.version ?? 0,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
});

export const getJobEvent = (
  db: Database,
  tenantId: string,
  id: string
): JobEvent | undefined => {
  const row = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              job_id AS jobId,
              event_type AS eventType,
              payload,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM job_events
       WHERE tenant_id = ? AND id = ?`
    )
    .get(tenantId, id);

  return row ? rowToJobEvent(row) : undefined;
};

export const listJobEventsByJobId = (
  db: Database,
  tenantId: string,
  jobId: string
): JobEvent[] => {
  const rows = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              job_id AS jobId,
              event_type AS eventType,
              payload,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM job_events
       WHERE tenant_id = ? AND job_id = ?
       ORDER BY created_at ASC`
    )
    .all(tenantId, jobId);

  return rows.map(rowToJobEvent);
};

export const createJobEvent = (db: Database, input: JobEventCreateInput): JobEvent => {
  const statement = db.prepare(
    `INSERT INTO job_events (
       id,
       tenant_id,
       job_id,
       event_type,
       payload,
       object_type,
       status,
       version,
       created_at,
       updated_at
     )
     VALUES (
       @id,
       @tenant_id,
       @job_id,
       @event_type,
       @payload,
       COALESCE(@object_type, 'job_events'),
       COALESCE(@status, 'active'),
       COALESCE(@version, 0),
       COALESCE(@created_at, datetime('now')),
       COALESCE(@updated_at, datetime('now'))
     )`
  );

  statement.run({
    id: input.id,
    tenant_id: input.tenantId,
    job_id: input.jobId,
    event_type: input.eventType,
    payload: input.payload ?? null,
    object_type: input.objectType ?? null,
    status: input.status ?? null,
    version: input.version ?? null,
    created_at: input.createdAt ?? null,
    updated_at: input.updatedAt ?? null,
  });

  const inserted = getJobEvent(db, input.tenantId, input.id);
  if (!inserted) {
    throw new Error(`Job event not found after insert: ${input.id}`);
  }

  return inserted;
};

export const updateJobEvent = (
  db: Database,
  tenantId: string,
  id: string,
  input: JobEventUpdateInput
): JobEvent | undefined => {
  const updates: Record<string, unknown> = {};

  if (input.eventType !== undefined) updates["event_type"] = input.eventType;
  if (input.payload !== undefined) updates.payload = input.payload;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.status !== undefined) updates.status = input.status;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length > 0) {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    db.prepare(`UPDATE job_events SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });
  }

  return getJobEvent(db, tenantId, id);
};

export const deleteJobEvent = (db: Database, tenantId: string, id: string): boolean => {
  const result = db.prepare(`DELETE FROM job_events WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
  return result.changes > 0;
};
