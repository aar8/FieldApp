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
import { type DbError, TypedError } from "../types/errors.js";
import { err, ok, type Result } from "../types/result.js";
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
  get: (db: Database, tenantId: string, id: string) => Result<T, DbError>;
  insert: (db: Database, tenantId: string, change: SyncChange, current: T | undefined) => Result<any, DbError>;
  update: (db: Database, tenantId: string, change: SyncChange, current: T | undefined) => Result<any, DbError>;
  delete: (db: Database, tenantId: string, id: string) => Result<boolean, DbError>;
}

const ensureRecord = (data: unknown, entity: string): Result<ChangeRecord, DbError> => {
  if (data && typeof data === "object" && !Array.isArray(data)) {
    return ok(data as ChangeRecord);
  }

  return err({ code: `sync_invalid_payload_for_${entity}`, context: { entity, data } });
};

const requireString = (record: ChangeRecord, key: string, entity: string, code: string): Result<string, DbError> => {
  const value = record[key];
  if (typeof value === "string" && value.length > 0) {
    return ok(value);
  }

  return err({ code, context: { entity, key, record } });
};

const optionalString = (record: ChangeRecord, key: string, entity: string, code: string): Result<string | undefined, DbError> => {
  if (!(key in record)) {
    return ok(undefined);
  }

  const value = record[key];
  if (typeof value === "string") {
    return ok(value);
  }

  if (value === null || value === undefined) {
    return ok(undefined);
  }

  return err({ code, context: { entity, key, record } });
};

const optionalNullableString = (record: ChangeRecord, key: string, entity: string, code: string): Result<string | null | undefined, DbError> => {
  if (!(key in record)) {
    return ok(undefined);
  }

  const value = record[key];
  if (value === null) {
    return ok(null);
  }

  if (typeof value === "string") {
    return ok(value);
  }

  return err({ code, context: { entity, key, record } });
};

const requireNumber = (record: ChangeRecord, key: string, entity: string, code: string): Result<number, DbError> => {
  const value = record[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return ok(value);
  }

  return err({ code, context: { entity, key, record } });
};

const optionalNumber = (record: ChangeRecord, key: string, entity: string, code: string): Result<number | undefined, DbError> => {
  if (!(key in record)) {
    return ok(undefined);
  }

  const value = record[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return ok(value);
  }

  if (value === null || value === undefined) {
    return ok(undefined);
  }

  return err({ code, context: { entity, key, record } });
};

const optionalPayload = (record: ChangeRecord, key: string, entity: string, code: string): Result<string | null | undefined, DbError> => {
  if (!(key in record)) {
    return ok(undefined);
  }

  const value = record[key];
  if (value === null) {
    return ok(null);
  }

  if (typeof value === "string") {
    return ok(value);
  }

  if (typeof value === "object") {
    return ok(JSON.stringify(value));
  }

  return err({ code, context: { entity, key, record } });
};

const buildUserCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  email: requireString(record, "email", "user", "sync_missing_user_email").value!,
  displayName: requireString(record, "displayName", "user", "sync_missing_user_displayName").value!,
  role: optionalString(record, "role", "user", "sync_invalid_user_role").value,
  objectType: optionalString(record, "objectType", "user", "sync_invalid_user_objectType").value,
  status: optionalString(record, "status", "user", "sync_invalid_user_status").value,
  version: change.version,
  createdAt: optionalString(record, "createdAt", "user", "sync_invalid_user_createdAt").value,
  updatedAt: optionalString(record, "updatedAt", "user", "sync_invalid_user_updatedAt").value,
});

const buildUserUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  email: optionalString(record, "email", "user", "sync_invalid_user_email").value,
  displayName: optionalString(record, "displayName", "user", "sync_invalid_user_displayName").value,
  role: optionalString(record, "role", "user", "sync_invalid_user_role").value,
  objectType: optionalString(record, "objectType", "user", "sync_invalid_user_objectType").value,
  status: optionalString(record, "status", "user", "sync_invalid_user_status").value,
  version: change.version,
  updatedAt: optionalString(record, "updatedAt", "user", "sync_invalid_user_updatedAt").value,
});

const buildCustomerCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  name: requireString(record, "name", "customer", "sync_missing_customer_name").value!,
  contactEmail: optionalNullableString(record, "contactEmail", "customer", "sync_invalid_customer_contactEmail").value,
  phone: optionalNullableString(record, "phone", "customer", "sync_invalid_customer_phone").value,
  location: optionalNullableString(record, "location", "customer", "sync_invalid_customer_location").value,
  objectType: optionalString(record, "objectType", "customer", "sync_invalid_customer_objectType").value,
  status: optionalString(record, "status", "customer", "sync_invalid_customer_status").value,
  version: change.version,
  createdAt: optionalString(record, "createdAt", "customer", "sync_invalid_customer_createdAt").value,
  updatedAt: optionalString(record, "updatedAt", "customer", "sync_invalid_customer_updatedAt").value,
});

const buildCustomerUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  name: optionalString(record, "name", "customer", "sync_invalid_customer_name").value,
  contactEmail: optionalNullableString(record, "contactEmail", "customer", "sync_invalid_customer_contactEmail").value,
  phone: optionalNullableString(record, "phone", "customer", "sync_invalid_customer_phone").value,
  location: optionalNullableString(record, "location", "customer", "sync_invalid_customer_location").value,
  objectType: optionalString(record, "objectType", "customer", "sync_invalid_customer_objectType").value,
  status: optionalString(record, "status", "customer", "sync_invalid_customer_status").value,
  version: change.version,
  updatedAt: optionalString(record, "updatedAt", "customer", "sync_invalid_customer_updatedAt").value,
});

const buildJobCreateInput = (tenantId: string, change: SyncChange, record: ChangeRecord) => ({
  id: change.primaryKey,
  tenantId,
  customerId: requireString(record, "customerId", "job", "sync_missing_job_customerId").value!,
  assignedTo: optionalNullableString(record, "assignedTo", "job", "sync_invalid_job_assignedTo").value,
  status: optionalString(record, "status", "job", "sync_invalid_job_status").value,
  scheduledStart: optionalNullableString(record, "scheduledStart", "job", "sync_invalid_job_scheduledStart").value,
  scheduledEnd: optionalNullableString(record, "scheduledEnd", "job", "sync_invalid_job_scheduledEnd").value,
  notes: optionalNullableString(record, "notes", "job", "sync_invalid_job_notes").value,
  objectType: optionalString(record, "objectType", "job", "sync_invalid_job_objectType").value,
  version: change.version,
  createdAt: optionalString(record, "createdAt", "job", "sync_invalid_job_createdAt").value,
  updatedAt: optionalString(record, "updatedAt", "job", "sync_invalid_job_updatedAt").value,
});

const buildJobUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  customerId: optionalString(record, "customerId", "job", "sync_invalid_job_customerId").value,
  assignedTo: optionalNullableString(record, "assignedTo", "job", "sync_invalid_job_assignedTo").value,
  status: optionalString(record, "status", "job", "sync_invalid_job_status").value,
  scheduledStart: optionalNullableString(record, "scheduledStart", "job", "sync_invalid_job_scheduledStart").value,
  scheduledEnd: optionalNullableString(record, "scheduledEnd", "job", "sync_invalid_job_scheduledEnd").value,
  notes: optionalNullableString(record, "notes", "job", "sync_invalid_job_notes").value,
  objectType: optionalString(record, "objectType", "job", "sync_invalid_job_objectType").value,
  version: change.version,
  updatedAt: optionalString(record, "updatedAt", "job", "sync_invalid_job_updatedAt").value,
});

const buildJobEventCreateInput = (
  tenantId: string,
  change: SyncChange,
  record: ChangeRecord
) => ({
  id: change.primaryKey,
  tenantId,
  jobId: requireString(record, "jobId", "jobEvent", "sync_missing_jobEvent_jobId").value!,
  eventType: requireString(record, "eventType", "jobEvent", "sync_missing_jobEvent_eventType").value!,
  payload: optionalPayload(record, "payload", "jobEvent", "sync_invalid_jobEvent_payload").value,
  objectType: optionalString(record, "objectType", "jobEvent", "sync_invalid_jobEvent_objectType").value,
  status: optionalString(record, "status", "jobEvent", "sync_invalid_jobEvent_status").value,
  version: change.version,
  createdAt: optionalString(record, "createdAt", "jobEvent", "sync_invalid_jobEvent_createdAt").value,
  updatedAt: optionalString(record, "updatedAt", "jobEvent", "sync_invalid_jobEvent_updatedAt").value,
});

const buildJobEventUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  eventType: optionalString(record, "eventType", "jobEvent", "sync_invalid_jobEvent_eventType").value,
  payload: optionalPayload(record, "payload", "jobEvent", "sync_invalid_jobEvent_payload").value,
  objectType: optionalString(record, "objectType", "jobEvent", "sync_invalid_jobEvent_objectType").value,
  status: optionalString(record, "status", "jobEvent", "sync_invalid_jobEvent_status").value,
  version: change.version,
  updatedAt: optionalString(record, "updatedAt", "jobEvent", "sync_invalid_jobEvent_updatedAt").value,
});

const buildAttachmentCreateInput = (
  tenantId: string,
  change: SyncChange,
  record: ChangeRecord
) => ({
  id: change.primaryKey,
  tenantId,
  jobId: optionalNullableString(record, "jobId", "attachment", "sync_invalid_attachment_jobId").value,
  customerId: optionalNullableString(record, "customerId", "attachment", "sync_invalid_attachment_customerId").value,
  fileName: requireString(record, "fileName", "attachment", "sync_missing_attachment_fileName").value!,
  fileType: requireString(record, "fileType", "attachment", "sync_missing_attachment_fileType").value!,
  fileSize: requireNumber(record, "fileSize", "attachment", "sync_missing_attachment_fileSize").value!,
  checksum: optionalNullableString(record, "checksum", "attachment", "sync_invalid_attachment_checksum").value,
  objectType: optionalString(record, "objectType", "attachment", "sync_invalid_attachment_objectType").value,
  status: optionalString(record, "status", "attachment", "sync_invalid_attachment_status").value,
  version: change.version,
  createdAt: optionalString(record, "createdAt", "attachment", "sync_invalid_attachment_createdAt").value,
  updatedAt: optionalString(record, "updatedAt", "attachment", "sync_invalid_attachment_updatedAt").value,
});

const buildAttachmentUpdateInput = (change: SyncChange, record: ChangeRecord) => ({
  jobId: optionalNullableString(record, "jobId", "attachment", "sync_invalid_attachment_jobId").value,
  customerId: optionalNullableString(record, "customerId", "attachment", "sync_invalid_attachment_customerId").value,
  fileName: optionalString(record, "fileName", "attachment", "sync_invalid_attachment_fileName").value,
  fileType: optionalString(record, "fileType", "attachment", "sync_invalid_attachment_fileType").value,
  fileSize: optionalNumber(record, "fileSize", "attachment", "sync_invalid_attachment_fileSize").value,
  checksum: optionalNullableString(record, "checksum", "attachment", "sync_invalid_attachment_checksum").value,
  objectType: optionalString(record, "objectType", "attachment", "sync_invalid_attachment_objectType").value,
  status: optionalString(record, "status", "attachment", "sync_invalid_attachment_status").value,
  version: change.version,
  updatedAt: optionalString(record, "updatedAt", "attachment", "sync_invalid_attachment_updatedAt").value,
});

const userAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getUser(db, tenantId, id),
  insert: (db, tenantId, change, current) => {
    const recordResult = ensureRecord(change.data, "user");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    if (current) {
      const updateInput = buildUserUpdateInput(change, record);
      return updateUser(db, tenantId, change.primaryKey, updateInput);
    }

    const createInput = buildUserCreateInput(tenantId, change, record);
    return createUser(db, createInput);
  },
  update: (db, tenantId, change) => {
    const recordResult = ensureRecord(change.data, "user");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    const updateInput = buildUserUpdateInput(change, record);
    return updateUser(db, tenantId, change.primaryKey, updateInput);
  },
  delete: (db, tenantId, id) => deleteUser(db, tenantId, id),
};

const customerAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getCustomer(db, tenantId, id),
  insert: (db, tenantId, change, current) => {
    const recordResult = ensureRecord(change.data, "customer");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    if (current) {
      const updateInput = buildCustomerUpdateInput(change, record);
      return updateCustomer(db, tenantId, change.primaryKey, updateInput);
    }

    const createInput = buildCustomerCreateInput(tenantId, change, record);
    return createCustomer(db, createInput);
  },
  update: (db, tenantId, change) => {
    const recordResult = ensureRecord(change.data, "customer");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    const updateInput = buildCustomerUpdateInput(change, record);
    return updateCustomer(db, tenantId, change.primaryKey, updateInput);
  },
  delete: (db, tenantId, id) => deleteCustomer(db, tenantId, id),
};

const jobAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getJob(db, tenantId, id),
  insert: (db, tenantId, change, current) => {
    const recordResult = ensureRecord(change.data, "job");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    if (current) {
      const updateInput = buildJobUpdateInput(change, record);
      return updateJob(db, tenantId, change.primaryKey, updateInput);
    }

    const createInput = buildJobCreateInput(tenantId, change, record);
    return createJob(db, createInput);
  },
  update: (db, tenantId, change) => {
    const recordResult = ensureRecord(change.data, "job");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    const updateInput = buildJobUpdateInput(change, record);
    return updateJob(db, tenantId, change.primaryKey, updateInput);
  },
  delete: (db, tenantId, id) => deleteJob(db, tenantId, id),
};

const jobEventAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getJobEvent(db, tenantId, id),
  insert: (db, tenantId, change, current) => {
    const recordResult = ensureRecord(change.data, "jobEvent");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    if (current) {
      const updateInput = buildJobEventUpdateInput(change, record);
      return updateJobEvent(db, tenantId, change.primaryKey, updateInput);
    }

    const createInput = buildJobEventCreateInput(tenantId, change, record);
    return createJobEvent(db, createInput);
  },
  update: (db, tenantId, change) => {
    const recordResult = ensureRecord(change.data, "jobEvent");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    const updateInput = buildJobEventUpdateInput(change, record);
    return updateJobEvent(db, tenantId, change.primaryKey, updateInput);
  },
  delete: (db, tenantId, id) => deleteJobEvent(db, tenantId, id),
};

const attachmentAdapter: EntityAdapter<VersionedEntity> = {
  get: (db, tenantId, id) => getAttachment(db, tenantId, id),
  insert: (db, tenantId, change, current) => {
    const recordResult = ensureRecord(change.data, "attachment");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    if (current) {
      const updateInput = buildAttachmentUpdateInput(change, record);
      return updateAttachment(db, tenantId, change.primaryKey, updateInput);
    }

    const createInput = buildAttachmentCreateInput(tenantId, change, record);
    return createAttachment(db, createInput);
  },
  update: (db, tenantId, change) => {
    const recordResult = ensureRecord(change.data, "attachment");
    if (!recordResult.ok) return recordResult;
    const record = recordResult.value;

    const updateInput = buildAttachmentUpdateInput(change, record);
    return updateAttachment(db, tenantId, change.primaryKey, updateInput);
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
): Result<boolean, DbError> => {
  const adapter = entityAdapters[change.table];
  if (!adapter) {
    return err({ code: "sync_unsupported_table", context: { table: change.table } });
  }

  const currentResult = adapter.get(db, "", change.primaryKey);
  if (!currentResult.ok && !currentResult.error.code.endsWith("_not_found")) {
    return err(currentResult.error);
  }
  const current = currentResult.ok ? currentResult.value : undefined;

  if (current && change.version < current.version) {
    conflicts.push({
      entity: change.table,
      entityId: change.primaryKey,
      reason: `Incoming version ${change.version} is behind stored version ${current.version}`,
    });
    return ok(false);
  }

  switch (change.action) {
    case "insert": {
      const insertResult = adapter.insert(db, "", change, current);
      if (!insertResult.ok) return insertResult;
      return ok(true);
    }
    case "update": {
      if (!current) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Update ignored because target row was not found",
        });
        return ok(false);
      }

      const updateResult = adapter.update(db, "", change, current);
      if (!updateResult.ok) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Update failed",
        });
        return err(updateResult.error);
      }
      return ok(true);
    }
    case "delete": {
      const deleteResult = adapter.delete(db, "", change.primaryKey);
      if (!deleteResult.ok) {
        conflicts.push({
          entity: change.table,
          entityId: change.primaryKey,
          reason: "Delete failed",
        });
        return err(deleteResult.error);
      }
      return ok(true);
    }
    default: {
      return err({ code: "sync_unsupported_action", context: { action: change.action } });
    }
  }
};

export const registerSyncRoute = (router: Router): void => {
  router.post("/sync", async (req, res, next) => {
    const parsed = syncPayloadSchema.safeParse(req.body);
    if (!parsed.success) {
      return next(new TypedError("", {
        status: 400,
        code: "sync_invalid_payload",
        details: parsed.error.flatten(),
      }));
    }

    const { changes } = parsed.data;
    const conflicts: SyncConflict[] = [];
    let appliedChanges = 0;

    const dbResult = await withDatabase((db) => {
      const transactional = db.transaction((batchedChanges: typeof changes) => {
        for (const change of batchedChanges) {
          const appliedResult = applyChange(change, conflicts, db);
          if (appliedResult.ok && appliedResult.value) {
            appliedChanges += 1;
          } else if (!appliedResult.ok) {
            // This will roll back the transaction
            throw new TypedError("", { status: 400, code: appliedResult.error.code, details: appliedResult.error.context });
          }
        }
      });

      try {
        transactional(changes);
        return ok(true);
      } catch (error) {
        if (error instanceof TypedError) {
          return err(error);
        }
        return err(new TypedError("", { status: 500, code: "sync_transaction_failed", details: error }));
      }
    });

    if (!dbResult.ok) {
      return next(dbResult.error);
    }

    const payload: SyncResult = {
      summary: {
        appliedChanges,
        pendingChanges: conflicts.length,
        lastSyncedAt: new Date().toISOString(),
      },
      conflicts,
    };

    res.json(payload);
  });
};
