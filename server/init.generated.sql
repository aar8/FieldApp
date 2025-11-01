-- GENERATED FILE — DO NOT EDIT
-- Run: npm run build && npm run generate

CREATE TABLE jobs (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'job',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE tenants (
  id TEXT PRIMARY KEY NOT NULL,
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL
);

CREATE TABLE users (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'user',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE customers (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'customer',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE calendar_events (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'calendar_event',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE pricebooks (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'pricebook',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE products (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'product',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE locations (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'location',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE product_items (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'product_item',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE pricebook_entries (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'pricebook_entry',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE job_line_items (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'job_line_item',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE quotes (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'quote',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE object_feeds (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'object_feed',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE invoices (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'invoice',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE invoice_line_items (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT NOT NULL REFERENCES tenants(id),
  status TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL,
  object_name TEXT NOT NULL DEFAULT 'invoice_line_item',
  object_type TEXT NOT NULL,
  data JSON NOT NULL
);

CREATE TABLE object_metadata (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT REFERENCES tenants(id),
  object_name TEXT NOT NULL,
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL
);

CREATE TABLE layout_definitions (
  id TEXT PRIMARY KEY NOT NULL,
  tenant_id TEXT REFERENCES tenants(id),
  object_name TEXT NOT NULL,
  object_type TEXT NOT NULL,
  status TEXT NOT NULL,
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT REFERENCES users(id),
  modified_by TEXT REFERENCES users(id),
  created_at TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  updated_at TEXT NOT NULL
);
