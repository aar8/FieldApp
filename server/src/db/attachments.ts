import type { Database } from "better-sqlite3";

export interface Attachment {
  readonly id: string;
  readonly tenantId: string;
  readonly jobId: string | null;
  readonly customerId: string | null;
  readonly fileName: string;
  readonly fileType: string;
  readonly fileSize: number;
  readonly checksum: string | null;
  readonly objectType: string;
  readonly status: string;
  readonly version: number;
  readonly createdAt: string;
  readonly updatedAt: string;
}

export interface AttachmentCreateInput {
  readonly id: string;
  readonly tenantId: string;
  readonly jobId?: string | null;
  readonly customerId?: string | null;
  readonly fileName: string;
  readonly fileType: string;
  readonly fileSize: number;
  readonly checksum?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly createdAt?: string;
  readonly updatedAt?: string;
}

export interface AttachmentUpdateInput {
  readonly jobId?: string | null;
  readonly customerId?: string | null;
  readonly fileName?: string;
  readonly fileType?: string;
  readonly fileSize?: number;
  readonly checksum?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly updatedAt?: string;
}

const rowToAttachment = (row: any): Attachment => ({
  id: row.id,
  tenantId: row.tenantId,
  jobId: row.jobId ?? null,
  customerId: row.customerId ?? null,
  fileName: row.fileName,
  fileType: row.fileType,
  fileSize: row.fileSize,
  checksum: row.checksum ?? null,
  objectType: row.objectType,
  status: row.status,
  version: row.version ?? 0,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
});

export const getAttachment = (
  db: Database,
  tenantId: string,
  id: string
): Attachment | undefined => {
  const row = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              job_id AS jobId,
              customer_id AS customerId,
              file_name AS fileName,
              file_type AS fileType,
              file_size AS fileSize,
              checksum,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM attachments
       WHERE tenant_id = ? AND id = ?`
    )
    .get(tenantId, id);

  return row ? rowToAttachment(row) : undefined;
};

export const createAttachment = (db: Database, input: AttachmentCreateInput): Attachment => {
  const statement = db.prepare(
    `INSERT INTO attachments (
       id,
       tenant_id,
       job_id,
       customer_id,
       file_name,
       file_type,
       file_size,
       checksum,
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
       @customer_id,
       @file_name,
       @file_type,
       @file_size,
       @checksum,
       COALESCE(@object_type, 'attachments'),
       COALESCE(@status, 'active'),
       COALESCE(@version, 0),
       COALESCE(@created_at, datetime('now')),
       COALESCE(@updated_at, datetime('now'))
     )`
  );

  statement.run({
    id: input.id,
    tenant_id: input.tenantId,
    job_id: input.jobId ?? null,
    customer_id: input.customerId ?? null,
    file_name: input.fileName,
    file_type: input.fileType,
    file_size: input.fileSize,
    checksum: input.checksum ?? null,
    object_type: input.objectType ?? null,
    status: input.status ?? null,
    version: input.version ?? null,
    created_at: input.createdAt ?? null,
    updated_at: input.updatedAt ?? null,
  });

  const created = getAttachment(db, input.tenantId, input.id);
  if (!created) {
    throw new Error(`Attachment not found after insert: ${input.id}`);
  }

  return created;
};

export const updateAttachment = (
  db: Database,
  tenantId: string,
  id: string,
  input: AttachmentUpdateInput
): Attachment | undefined => {
  const updates: Record<string, unknown> = {};

  if (input.jobId !== undefined) updates["job_id"] = input.jobId;
  if (input.customerId !== undefined) updates["customer_id"] = input.customerId;
  if (input.fileName !== undefined) updates["file_name"] = input.fileName;
  if (input.fileType !== undefined) updates["file_type"] = input.fileType;
  if (input.fileSize !== undefined) updates["file_size"] = input.fileSize;
  if (input.checksum !== undefined) updates.checksum = input.checksum;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.status !== undefined) updates.status = input.status;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length > 0) {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    db.prepare(`UPDATE attachments SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });
  }

  return getAttachment(db, tenantId, id);
};

export const deleteAttachment = (db: Database, tenantId: string, id: string): boolean => {
  const result = db.prepare(`DELETE FROM attachments WHERE tenant_id = ? AND id = ?`).run(
    tenantId,
    id
  );
  return result.changes > 0;
};
