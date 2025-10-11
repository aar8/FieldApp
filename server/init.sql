-- =============================================================
-- 🧩 DESIGN NOTE: JSON1-BASED FLEXIBLE SCHEMA STRATEGY
-- =============================================================
-- We use SQLite’s built-in JSON1 extension to store entity
-- attributes (layout definitions, job payloads, customer data,
-- etc.) as structured JSON blobs rather than rigid columns.
--
-- This gives several advantages:
--   • Schema agility — new fields can be added client-side and
--     stored immediately without requiring a migration.
--   • Versioned decoding — server code can interpret legacy
--     records safely while newer app builds use richer schemas.
--   • Cross-tenant isolation — each tenant can have unique
--     layout definitions or object models that evolve separately.
--   • Simplified sync — JSON1 allows direct filtering,
--     projection, and partial updates via `json_extract` and
--     `json_set`, reducing translation overhead.
--
-- Example:
--   SELECT json_extract(schema, '$.settings.theme') FROM tenants;
--
-- Each table uses:
--   - `schema` JSON column for the entity body
--   - `version` INTEGER for optimistic concurrency control
--   - `created_by` TEXT for audit trails
--   - `created_at` TEXT with `datetime('now')` default
--   - Optional `tenant_id` TEXT FK to `tenants`
--
-- This approach keeps the data model future-proof while allowing
-- fast iteration on layouts and field definitions.
-- =============================================================

-- =============================================================
-- UNIFIED ENTITY MODEL USING JSON1
-- =============================================================
-- All entities share this pattern:
--   id TEXT PRIMARY KEY
--   tenant_id TEXT NOT NULL REFERENCES tenants(id)
--   object_type TEXT NOT NULL                 -- logical type (e.g. "job", "customer")
--   status TEXT DEFAULT 'active'              -- domain state
--   data JSON NOT NULL                        -- entity payload (flexible JSON1)
--   version INTEGER NOT NULL DEFAULT 0        -- optimistic concurrency
--   created_by TEXT                           -- user id who created it
--   modified_by TEXT                          -- user id who last modified it
--   created_at TEXT NOT NULL DEFAULT (datetime('now'))
--   updated_at TEXT NOT NULL DEFAULT (datetime('now'))
-- =============================================================

CREATE TABLE IF NOT EXISTS tenants (
  id TEXT PRIMARY KEY,
  schema JSON NOT NULL,   -- { "name": "Cool HVAC LLC", "plan": "pro", "settings": { ... } }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL DEFAULT 'job',
  status TEXT NOT NULL DEFAULT 'scheduled',
  data JSON NOT NULL, -- { "customer_id": "...", "assigned_to": "...", "notes": "...", "custom_fields": {...} }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL DEFAULT 'user',
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,      -- { "email": "...", "display_name": "...", "role": "tech|admin" }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL DEFAULT 'customer',
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,      -- { "name": "...", "contact": { "email": "...", "phone": "..." }, "address": {...} }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);


CREATE TABLE IF NOT EXISTS attachments (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL DEFAULT 'attachment',
  status TEXT DEFAULT 'stored',
  data JSON NOT NULL,      -- { "linked_id": "...", "file_name": "...", "file_type": "...", "size": 12345 }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS devices (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL DEFAULT 'device',
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,      -- { "user_id": "...", "platform": "ios|android|web", "app_version": "1.0.2", "last_seen": "...", "revoked": false }
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =============================================================
-- INDEXES
-- =============================================================

-- Index on tenant name for fast lookups
CREATE INDEX IF NOT EXISTS idx_tenants_name ON tenants(json_extract(schema, '$.name'));

-- Indexes for jobs
CREATE INDEX IF NOT EXISTS idx_jobs_tenant_id ON jobs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);

-- Indexes for users
CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Indexes for customers
CREATE INDEX IF NOT EXISTS idx_customers_tenant_id ON customers(tenant_id);

-- Indexes for attachments
CREATE INDEX IF NOT EXISTS idx_attachments_tenant_id ON attachments(tenant_id);

-- Indexes for devices
CREATE INDEX IF NOT EXISTS idx_devices_tenant_id ON devices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);


-- =============================================================
-- TRIGGERS FOR AUTOMATICALLY UPDATING `updated_at`
-- =============================================================

CREATE TRIGGER IF NOT EXISTS set_tenants_updated_at
AFTER UPDATE ON tenants FOR EACH ROW BEGIN
  UPDATE tenants SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_jobs_updated_at
AFTER UPDATE ON jobs FOR EACH ROW BEGIN
  UPDATE jobs SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_users_updated_at
AFTER UPDATE ON users FOR EACH ROW BEGIN
  UPDATE users SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_customers_updated_at
AFTER UPDATE ON customers FOR EACH ROW BEGIN
  UPDATE customers SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_attachments_updated_at
AFTER UPDATE ON attachments FOR EACH ROW BEGIN
  UPDATE attachments SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_devices_updated_at
AFTER UPDATE ON devices FOR EACH ROW BEGIN
  UPDATE devices SET updated_at = datetime('now') WHERE id = OLD.id;
END;
