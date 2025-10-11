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

-- =============================================================
-- OBJECT METADATA AND LAYOUT SYSTEM OVERVIEW
-- =============================================================
-- PURPOSE:
--   This subsystem defines how FieldPrime dynamically renders and validates
--   objects without schema migrations. It drives forms, filters, and layout
--   behavior using metadata stored in SQLite (queryable via JSON1).
--
-- CONCEPTS:
--   1. OBJECT METADATA
--      - Each record in `object_metadata` describes the field definitions
--        available for a given objectType (e.g., "job", "customer").
--      - The `data` JSON contains the field schema, which is an array of fields.
--
--   2. FIELD TYPES (SUPPORTED)
--      - Supported base types are kept intentionally simple for mobile use.
--      - Future additions can include more complex types or formats.
--
--      - BASE TYPES:
--            string      -- Free text. Can use a 'format' property for subtypes (e.g., email, phone, url).
--            date        -- ISO-8601 string, stored in UTC.
--            picklist    -- Fixed set of options, defined in an 'options' array.
--            checkbox    -- A boolean UI element, stored as an INTEGER (0 or 1).
--            bool        -- An alias for checkbox.
--            numeric     -- Integer or floating-point values.
--            currency    -- Decimal values. Can include 'precision' and 'currencyCode' properties.
--            reference   -- A link to another object, defining a many-to-one relationship.
--            file        -- A reference to a record in the 'attachments' table.
--
--      - FIELD DEFINITION EXAMPLES:
--          // Simple string
--          { "name": "title", "label": "Job Title", "type": "string", "required": true }
--
--          // String with a specific format for UI/validation hints
--          { "name": "contact_email", "label": "Contact Email", "type": "string", "format": "email" }
--
--          // Picklist with options
--          { "name": "priority", "label": "Priority", "type": "picklist", "options": ["Low","Medium","High"] }
--
--          // A reference field, creating a link to a customer record
--          { "name": "customer", "label": "Customer", "type": "reference", "target_object": "customer" }
--
--      - Dependent picklists are not supported initially to avoid field-level coupling.
--        They can be added later by allowing a "dependsOn" property in the field JSON:
--            { "name": "model", "type": "picklist", "dependsOn": "brand", "source": "..." }
--
--   3. LAYOUTS
--      - Layouts describe how fields are presented on screen.
--      - Each layout is bound to a combination of (objectType, status).
--        Example: ("job", "scheduled") may use a different layout than ("job", "completed").
--      - The layout JSON defines sections and the order of fields (by name):
--          {
--            "sections": [
--              { "label": "Job Info", "fields": ["title", "customer", "priority"] },
--              { "label": "Scheduling", "fields": ["scheduled_date"] }
--            ]
--          }
--
--   4. HOW IT FITS:
--      - The app loads metadata once and caches it locally.
--      - When displaying or editing a record, the system:
--          a. Looks up metadata by objectType.
--          b. Selects a layout by (objectType, status).
--          c. Renders the UI based on the layout and field definitions.
--          d. Validates input according to field definitions (`required`, `type`, `format`, etc.).
--
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
-- METADATA & LAYOUT DEFINITION TABLES
-- =============================================================

CREATE TABLE IF NOT EXISTS object_metadata (
  id TEXT PRIMARY KEY,
  -- A NULL tenant_id can represent global, default metadata
  tenant_id TEXT REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL,
  data JSON NOT NULL, -- The field definitions JSON blob from the comments
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS layout_definitions (
  id TEXT PRIMARY KEY,
  -- A NULL tenant_id can represent global, default layouts
  tenant_id TEXT REFERENCES tenants(id) ON DELETE CASCADE,
  object_type TEXT NOT NULL,
  -- A NULL status can represent the default layout for the object type
  status TEXT,
  data JSON NOT NULL, -- The layout JSON blob from the comments
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

-- Indexes for metadata
CREATE UNIQUE INDEX IF NOT EXISTS idx_object_metadata_uniq
  ON object_metadata(COALESCE(tenant_id, 'global'), object_type);

CREATE UNIQUE INDEX IF NOT EXISTS idx_layout_definitions_uniq
  ON layout_definitions(COALESCE(tenant_id, 'global'), object_type, COALESCE(status, 'default'));


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

CREATE TRIGGER IF NOT EXISTS set_object_metadata_updated_at
AFTER UPDATE ON object_metadata FOR EACH ROW BEGIN
  UPDATE object_metadata SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_layout_definitions_updated_at
AFTER UPDATE ON layout_definitions FOR EACH ROW BEGIN
  UPDATE layout_definitions SET updated_at = datetime('now') WHERE id = OLD.id;
END;
