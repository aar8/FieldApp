import type { Database } from "better-sqlite3";
import type { DbError } from "../types/errors.js";
import { err, ok, type Result } from "../types/result.js";

export interface User {
  readonly id: string;
  readonly tenantId: string;
  readonly email: string;
  readonly displayName: string;
  readonly role: string;
  readonly objectType: string;
  readonly status: string;
  readonly version: number;
  readonly createdAt: string;
  readonly updatedAt: string;
}

export interface UserCreateInput {
  readonly id: string;
  readonly tenantId: string;
  readonly email: string;
  readonly displayName: string;
  readonly role?: string;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly createdAt?: string;
  readonly updatedAt?: string;
}

export interface UserUpdateInput {
  readonly email?: string;
  readonly displayName?: string;
  readonly role?: string;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly updatedAt?: string;
}

const rowToUser = (row: any): User => ({
  id: row.id,
  tenantId: row.tenantId,
  email: row.email,
  displayName: row.displayName,
  role: row.role,
  objectType: row.objectType,
  status: row.status,
  version: row.version ?? 0,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
});

export const listUsers = (db: Database, tenantId: string): User[] => {
  const rows = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              email,
              display_name AS displayName,
              role,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM users
       WHERE tenant_id = ?
       ORDER BY created_at DESC`
    )
    .all(tenantId);

  return rows.map(rowToUser);
};

export const getUser = (
  db: Database,
  tenantId: string,
  id: string
): Result<User, DbError> => {
  try {
    const row = db
      .prepare(
        `SELECT id,
                tenant_id AS tenantId,
                email,
                display_name AS displayName,
                role,
                object_type AS objectType,
                status,
                version,
                created_at AS createdAt,
                updated_at AS updatedAt
         FROM users
         WHERE tenant_id = ? AND id = ?`
      )
      .get(tenantId, id);

    if (!row) {
      return err({ code: "get_user_not_found", context: { tenantId, id } });
    }

    return ok(rowToUser(row));
  } catch (error) {
    if (error instanceof Error) {
      return err({ code: "get_user_exception", context: { tenantId, id, error: error.message } });
    }
    return err({ code: "get_user_unknown_error", context: { tenantId, id } });
  }
};

export const createUser = (
  db: Database,
  input: UserCreateInput
): Result<User, DbError> => {
  try {
    const statement = db.prepare(
      `INSERT INTO users (
         id,
         tenant_id,
         email,
         display_name,
         role,
         object_type,
         status,
         version,
         created_at,
         updated_at
       )
       VALUES (
         @id,
         @tenant_id,
         @email,
         @display_name,
         COALESCE(@role, 'field-tech'),
         COALESCE(@object_type, 'users'),
         COALESCE(@status, 'active'),
         COALESCE(@version, 0),
         COALESCE(@created_at, datetime('now')),
         COALESCE(@updated_at, datetime('now'))
       )`
    );

    statement.run({
      id: input.id,
      tenant_id: input.tenantId,
      email: input.email,
      display_name: input.displayName,
      role: input.role ?? null,
      object_type: input.objectType ?? null,
      status: input.status ?? null,
      version: input.version ?? null,
      created_at: input.createdAt ?? null,
      updated_at: input.updatedAt ?? null,
    });

    return getUser(db, input.tenantId, input.id);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "create_user_exception", 
        context: { input, error: error.message } 
      });
    }
    return err({ 
      code: "create_user_unknown_error", 
      context: { input }
    });
  }
};

export const updateUser = (
  db: Database,
  tenantId: string,
  id: string,
  input: UserUpdateInput
): Result<User, DbError> => {
  const updates: Record<string, unknown> = {};

  if (input.email !== undefined) updates.email = input.email;
  if (input.displayName !== undefined) updates["display_name"] = input.displayName;
  if (input.role !== undefined) updates.role = input.role;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.status !== undefined) updates.status = input.status;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length === 0) {
    return getUser(db, tenantId, id);
  }

  try {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    const result = db
      .prepare(`UPDATE users SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`)
      .run({
        ...updates,
        tenant_id: tenantId,
        id,
      });

    if (result.changes === 0) {
      return err({ 
        code: "update_user_not_found_or_no_changes", 
        context: { tenantId, id, input }
      });
    }

    return getUser(db, tenantId, id);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "update_user_exception", 
        context: { tenantId, id, input, error: error.message }
      });
    }
    return err({ 
      code: "update_user_unknown_error", 
      context: { tenantId, id, input }
    });
  }
};

export const deleteUser = (
  db: Database,
  tenantId: string,
  id: string
): Result<boolean, DbError> => {
  try {
    const result = db.prepare(`DELETE FROM users WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
    return ok(result.changes > 0);
  } catch (error) {
    if (error instanceof Error) {
      return err({ 
        code: "delete_user_exception", 
        context: { tenantId, id, error: error.message }
      });
    }
    return err({ 
      code: "delete_user_unknown_error", 
      context: { tenantId, id }
    });
  }
};
