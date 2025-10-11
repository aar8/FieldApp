import type { Database } from "better-sqlite3";
import type { DbError } from "../types/errors.js";
import { err, ok, type Result } from "../types/result.js";

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
): Result<Attachment, DbError> => {
  try {
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

    if (!row) {
      return err({ code: "get_attachment_not_found", context: { tenantId, id } });
    }

    return ok(rowToAttachment(row));
  } catch (error) {
    if (error instanceof Error) {
      return err({ code: "get_attachment_exception", context: { tenantId, id, error: error.message } });
    }
    return err({ code: "get_attachment_unknown_error", context: { tenantId, id } });
  }
};

export const createAttachment = (db: Database, input: AttachmentCreateInput): Result<Attachment, DbError> => {
  try {
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

    return getAttachment(db, input.tenantId, input.id);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "create_attachment_exception", 
        context: { input, error: error.message } 
      });
    }
    return err({ 
      code: "create_attachment_unknown_error", 
      context: { input }
    });
  }
};

export const updateAttachment = (
  db: Database,
  tenantId: string,
  id: string,
  input: AttachmentUpdateInput
): Result<Attachment, DbError> => {
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
  if (keys.length === 0) {
    return getAttachment(db, tenantId, id);
  }

  try {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    const result = db.prepare(`UPDATE attachments SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });

    if (result.changes === 0) {
      return err({ 
        code: "update_attachment_not_found_or_no_changes", 
        context: { tenantId, id, input }
      });
    }

    return getAttachment(db, tenantId, id);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "update_attachment_exception", 
        context: { tenantId, id, input, error: error.message }
      });
    }
    return err({ 
      code: "update_attachment_unknown_error", 
      context: { tenantId, id, input }
    });
  }
};

export const deleteAttachment = (db: Database, tenantId: string, id: string): Result<boolean, DbError> => {
  try {
    const result = db.prepare(`DELETE FROM attachments WHERE tenant_id = ? AND id = ?`).run(
      tenantId,
      id
    );
    return ok(result.changes > 0);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "delete_attachment_exception", 
        context: { tenantId, id, error: error.message }
      });
    }
    return err({ 
      code: "delete_attachment_unknown_error", 
      context: { tenantId, id }
    });
  }
};
