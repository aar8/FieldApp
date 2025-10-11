import type { Database } from "better-sqlite3";

export interface Job {
  readonly id: string;
  readonly tenantId: string;
  readonly customerId: string;
  readonly assignedTo: string | null;
  readonly status: string;
  readonly scheduledStart: string | null;
  readonly scheduledEnd: string | null;
  readonly notes: string | null;
  readonly objectType: string;
  readonly version: number;
  readonly createdAt: string;
  readonly updatedAt: string;
  readonly customerName?: string | null;
}

export interface JobCreateInput {
  readonly id: string;
  readonly tenantId: string;
  readonly customerId: string;
  readonly assignedTo?: string | null;
  readonly status?: string;
  readonly scheduledStart?: string | null;
  readonly scheduledEnd?: string | null;
  readonly notes?: string | null;
  readonly objectType?: string;
  readonly version?: number;
  readonly createdAt?: string;
  readonly updatedAt?: string;
}

export interface JobUpdateInput {
  readonly customerId?: string;
  readonly assignedTo?: string | null;
  readonly status?: string;
  readonly scheduledStart?: string | null;
  readonly scheduledEnd?: string | null;
  readonly notes?: string | null;
  readonly objectType?: string;
  readonly version?: number;
  readonly updatedAt?: string;
}

const rowToJob = (row: any): Job => ({
  id: row.id,
  tenantId: row.tenantId,
  customerId: row.customerId,
  assignedTo: row.assignedTo ?? null,
  status: row.status,
  scheduledStart: row.scheduledStart ?? null,
  scheduledEnd: row.scheduledEnd ?? null,
  notes: row.notes ?? null,
  objectType: row.objectType,
  version: row.version ?? 0,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
  customerName: row.customerName ?? null,
});

export const listJobs = (db: Database, tenantId: string): Job[] => {
  const rows = db
    .prepare(
      `SELECT
         jobs.id,
         jobs.tenant_id AS tenantId,
         jobs.customer_id AS customerId,
         jobs.assigned_to AS assignedTo,
         jobs.status,
         jobs.scheduled_start AS scheduledStart,
         jobs.scheduled_end AS scheduledEnd,
         jobs.notes AS notes,
         jobs.object_type AS objectType,
         jobs.version AS version,
         jobs.created_at AS createdAt,
         jobs.updated_at AS updatedAt,
         customers.name AS customerName
       FROM jobs
       LEFT JOIN customers
         ON customers.tenant_id = jobs.tenant_id
        AND customers.id = jobs.customer_id
       WHERE jobs.tenant_id = ?
       ORDER BY jobs.created_at DESC`
    )
    .all(tenantId);

  return rows.map(rowToJob);
};

export const getJob = (db: Database, tenantId: string, id: string): Job | undefined => {
  const row = db
    .prepare(
      `SELECT
         jobs.id,
         jobs.tenant_id AS tenantId,
         jobs.customer_id AS customerId,
         jobs.assigned_to AS assignedTo,
         jobs.status,
         jobs.scheduled_start AS scheduledStart,
         jobs.scheduled_end AS scheduledEnd,
         jobs.notes AS notes,
         jobs.object_type AS objectType,
         jobs.version AS version,
         jobs.created_at AS createdAt,
         jobs.updated_at AS updatedAt,
         customers.name AS customerName
       FROM jobs
       LEFT JOIN customers
         ON customers.tenant_id = jobs.tenant_id
        AND customers.id = jobs.customer_id
       WHERE jobs.tenant_id = ? AND jobs.id = ?`
    )
    .get(tenantId, id);

  return row ? rowToJob(row) : undefined;
};

export const createJob = (db: Database, input: JobCreateInput): Job => {
  const statement = db.prepare(
    `INSERT INTO jobs (
       id,
       tenant_id,
       customer_id,
       assigned_to,
       status,
       scheduled_start,
       scheduled_end,
       notes,
       object_type,
       version,
       created_at,
       updated_at
     )
     VALUES (
       @id,
       @tenant_id,
       @customer_id,
       @assigned_to,
       COALESCE(@status, 'scheduled'),
       @scheduled_start,
       @scheduled_end,
       @notes,
       COALESCE(@object_type, 'jobs'),
       COALESCE(@version, 0),
       COALESCE(@created_at, datetime('now')),
       COALESCE(@updated_at, datetime('now'))
     )`
  );

  statement.run({
    id: input.id,
    tenant_id: input.tenantId,
    customer_id: input.customerId,
    assigned_to: input.assignedTo ?? null,
    status: input.status ?? null,
    scheduled_start: input.scheduledStart ?? null,
    scheduled_end: input.scheduledEnd ?? null,
    notes: input.notes ?? null,
    object_type: input.objectType ?? null,
    version: input.version ?? null,
    created_at: input.createdAt ?? null,
    updated_at: input.updatedAt ?? null,
  });

  const created = getJob(db, input.tenantId, input.id);
  if (!created) {
    throw new Error(`Failed to load job after insert: ${input.id}`);
  }

  return created;
};

export const updateJob = (
  db: Database,
  tenantId: string,
  id: string,
  input: JobUpdateInput
): Job | undefined => {
  const updates: Record<string, unknown> = {};

  if (input.customerId !== undefined) updates["customer_id"] = input.customerId;
  if (input.assignedTo !== undefined) updates["assigned_to"] = input.assignedTo;
  if (input.status !== undefined) updates.status = input.status;
  if (input.scheduledStart !== undefined) updates["scheduled_start"] = input.scheduledStart;
  if (input.scheduledEnd !== undefined) updates["scheduled_end"] = input.scheduledEnd;
  if (input.notes !== undefined) updates.notes = input.notes;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length > 0) {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    db.prepare(`UPDATE jobs SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });
  }

  return getJob(db, tenantId, id);
};

export const deleteJob = (db: Database, tenantId: string, id: string): boolean => {
  const result = db.prepare(`DELETE FROM jobs WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
  return result.changes > 0;
};
