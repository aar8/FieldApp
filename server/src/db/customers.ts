import type { Database } from "better-sqlite3";

export interface Customer {
  readonly id: string;
  readonly tenantId: string;
  readonly name: string;
  readonly contactEmail: string | null;
  readonly phone: string | null;
  readonly location: string | null;
  readonly objectType: string;
  readonly status: string;
  readonly version: number;
  readonly createdAt: string;
  readonly updatedAt: string;
}

export interface CustomerCreateInput {
  readonly id: string;
  readonly tenantId: string;
  readonly name: string;
  readonly contactEmail?: string | null;
  readonly phone?: string | null;
  readonly location?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly createdAt?: string;
  readonly updatedAt?: string;
}

export interface CustomerUpdateInput {
  readonly name?: string;
  readonly contactEmail?: string | null;
  readonly phone?: string | null;
  readonly location?: string | null;
  readonly objectType?: string;
  readonly status?: string;
  readonly version?: number;
  readonly updatedAt?: string;
}

const rowToCustomer = (row: any): Customer => ({
  id: row.id,
  tenantId: row.tenantId,
  name: row.name,
  contactEmail: row.contactEmail ?? null,
  phone: row.phone ?? null,
  location: row.location ?? null,
  objectType: row.objectType,
  status: row.status,
  version: row.version ?? 0,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
});

export const listCustomers = (db: Database, tenantId: string): Customer[] => {
  const rows = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              name,
              contact_email AS contactEmail,
              phone,
              location,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM customers
       WHERE tenant_id = ?
       ORDER BY name ASC`
    )
    .all(tenantId);

  return rows.map(rowToCustomer);
};

export const getCustomer = (
  db: Database,
  tenantId: string,
  id: string
): Customer | undefined => {
  const row = db
    .prepare(
      `SELECT id,
              tenant_id AS tenantId,
              name,
              contact_email AS contactEmail,
              phone,
              location,
              object_type AS objectType,
              status,
              version,
              created_at AS createdAt,
              updated_at AS updatedAt
       FROM customers
       WHERE tenant_id = ? AND id = ?`
    )
    .get(tenantId, id);

  return row ? rowToCustomer(row) : undefined;
};

export const createCustomer = (db: Database, input: CustomerCreateInput): Customer => {
  const statement = db.prepare(
    `INSERT INTO customers (
       id,
       tenant_id,
       name,
       contact_email,
       phone,
       location,
       object_type,
       status,
       version,
       created_at,
       updated_at
     )
     VALUES (
       @id,
       @tenant_id,
       @name,
       @contact_email,
       @phone,
       @location,
       COALESCE(@object_type, 'customers'),
       COALESCE(@status, 'active'),
       COALESCE(@version, 0),
       COALESCE(@created_at, datetime('now')),
       COALESCE(@updated_at, datetime('now'))
     )`
  );

  statement.run({
    id: input.id,
    tenant_id: input.tenantId,
    name: input.name,
    contact_email: input.contactEmail ?? null,
    phone: input.phone ?? null,
    location: input.location ?? null,
    object_type: input.objectType ?? null,
    status: input.status ?? null,
    version: input.version ?? null,
    created_at: input.createdAt ?? null,
    updated_at: input.updatedAt ?? null,
  });

  const created = getCustomer(db, input.tenantId, input.id);
  if (!created) {
    throw new Error(`Failed to load customer after insert: ${input.id}`);
  }

  return created;
};

export const updateCustomer = (
  db: Database,
  tenantId: string,
  id: string,
  input: CustomerUpdateInput
): Customer | undefined => {
  const updates: Record<string, unknown> = {};

  if (input.name !== undefined) updates.name = input.name;
  if (input.contactEmail !== undefined) updates["contact_email"] = input.contactEmail;
  if (input.phone !== undefined) updates.phone = input.phone;
  if (input.location !== undefined) updates.location = input.location;
  if (input.objectType !== undefined) updates["object_type"] = input.objectType;
  if (input.status !== undefined) updates.status = input.status;
  if (input.version !== undefined) updates.version = input.version;
  updates.updated_at = input.updatedAt ?? new Date().toISOString();

  const keys = Object.keys(updates);
  if (keys.length > 0) {
    const assignments = keys.map((key) => `${key} = @${key}`).join(", ");
    db.prepare(`UPDATE customers SET ${assignments} WHERE tenant_id = @tenant_id AND id = @id`).run({
      ...updates,
      tenant_id: tenantId,
      id,
    });
  }

  return getCustomer(db, tenantId, id);
};

export const deleteCustomer = (db: Database, tenantId: string, id: string): boolean => {
  const result = db.prepare(`DELETE FROM customers WHERE tenant_id = ? AND id = ?`).run(tenantId, id);
  return result.changes > 0;
};
