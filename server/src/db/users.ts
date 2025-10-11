import type { Database } from "better-sqlite3";

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

export const getUser = (db: Database, tenantId: string, id: string): User | undefined => {
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

  return row ? rowToUser(row) : undefined;
};

export const createUser = (db: Database, input: UserCreateInput): User => {
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

  const created = getUser(db, input.tenantId, input.id);
  if (!created) {
    throw new Error(`Failed to load user after insert: ${input.id}`);
  }

  return created;
};

export const updateUser = (
  db: Database,
  tenantId: string,
  id: string,
  input: UserUpdateInput
): User | undefined => {
  const updates: Record<string, unknown> = {};

  if (input.email !== undefined) updates.email = input.email;
  if (input.displayName !== undefined) updates["display_name"] = input.displayName;
  if (input.role !== undefined) updates.role = input.role;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.status !== undefined) updates.status = input.status;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length > 0) {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    db.prepare(`UPDATE users SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });
  }

  return getUser(db, tenantId, id);
};

export const deleteUser = (db: Database, tenantId: string, id: string): boolean => {
  const result = db.prepare(`DELETE FROM users WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
  return result.changes > 0;
};
