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
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'job',
  object_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'scheduled',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'user',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'customer',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);



-- Represents scheduled work or non-work events (e.g., jobs, travel, PTO). Enables multi-day jobs, per-technician assignments, and integration with external calendars. References jobs.id when applicable.
CREATE TABLE IF NOT EXISTS calendar_events (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'calendar_event',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Defines the set of services, materials, and pricing rules available to a tenant. Can include currency, region, and effective dates.
CREATE TABLE IF NOT EXISTS pricebooks (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'pricebook',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Catalog of billable products (services, materials, etc.).
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'product',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Stores inventory locations (e.g., warehouses, technician vans).
CREATE TABLE IF NOT EXISTS locations (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'location',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Tracks the stock of a specific product at a specific location.
CREATE TABLE IF NOT EXISTS product_items (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'product_item',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Defines the price of a product within a specific pricebook.
CREATE TABLE IF NOT EXISTS pricebook_entries (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'pricebook_entry',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Represents a line item on a job, linking a product that was used or sold.
CREATE TABLE IF NOT EXISTS job_line_items (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'job_line_item',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS quotes (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'quote',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS object_feeds (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'object_feed',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS invoices (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'invoice',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS invoice_line_items (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL DEFAULT 'invoice_line_item',
  object_type TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  data JSON NOT NULL,
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
  tenant_id TEXT REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL,
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(tenant_id, object_name)
);

CREATE TABLE IF NOT EXISTS layout_definitions (
  id TEXT PRIMARY KEY,
  tenant_id TEXT REFERENCES tenants(id) ON DELETE CASCADE,
  object_name TEXT NOT NULL,
  object_type TEXT NOT NULL,
  status TEXT NOT NULL,
  data JSON NOT NULL,
  version INTEGER NOT NULL DEFAULT 0,
  created_by TEXT,
  modified_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(tenant_id, object_name, object_type, status)
);

-- =============================================================
-- INDEXES
-- =============================================================

-- Index on tenant name for fast lookups
CREATE INDEX IF NOT EXISTS idx_tenants_name ON tenants(json_extract(data, '$.name'));

-- Indexes for jobs
CREATE INDEX IF NOT EXISTS idx_jobs_tenant_id ON jobs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_created_at ON jobs(created_at);

-- Indexes for users
CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_users_status ON users(status);

-- Indexes for customers
CREATE INDEX IF NOT EXISTS idx_customers_tenant_id ON customers(tenant_id);



-- Indexes for calendar_events
CREATE INDEX IF NOT EXISTS idx_calendar_events_tenant_id ON calendar_events(tenant_id);
CREATE INDEX IF NOT EXISTS idx_calendar_events_status ON calendar_events(status);

-- Indexes for pricebooks
CREATE INDEX IF NOT EXISTS idx_pricebooks_tenant_id ON pricebooks(tenant_id);
CREATE INDEX IF NOT EXISTS idx_pricebooks_status ON pricebooks(status);

-- Indexes for products
CREATE INDEX IF NOT EXISTS idx_products_tenant_id ON products(tenant_id);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);

-- Indexes for locations
CREATE INDEX IF NOT EXISTS idx_locations_tenant_id ON locations(tenant_id);

-- Indexes for product_items
CREATE INDEX IF NOT EXISTS idx_product_items_tenant_id ON product_items(tenant_id);

-- Indexes for pricebook_entries
CREATE INDEX IF NOT EXISTS idx_pricebook_entries_tenant_id ON pricebook_entries(tenant_id);

-- Indexes for job_line_items
CREATE INDEX IF NOT EXISTS idx_job_line_items_tenant_id ON job_line_items(tenant_id);

-- Indexes for quotes
CREATE INDEX IF NOT EXISTS idx_quotes_tenant_id ON quotes(tenant_id);
CREATE INDEX IF NOT EXISTS idx_quotes_status ON quotes(status);

-- Indexes for object_feeds
CREATE INDEX IF NOT EXISTS idx_object_feeds_tenant_id ON object_feeds(tenant_id);
CREATE INDEX IF NOT EXISTS idx_object_feeds_status ON object_feeds(status);

-- Indexes for invoices
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_id ON invoices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON invoices(status);

-- Indexes for invoice_line_items
CREATE INDEX IF NOT EXISTS idx_invoice_line_items_tenant_id ON invoice_line_items(tenant_id);



-- Indexes for metadata
CREATE UNIQUE INDEX IF NOT EXISTS idx_object_metadata_uniq
  ON object_metadata(COALESCE(tenant_id, 'global'), object_name);

CREATE UNIQUE INDEX IF NOT EXISTS idx_layout_definitions_uniq
  ON layout_definitions(COALESCE(tenant_id, 'global'), object_name, object_type, COALESCE(status, 'default'));


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





CREATE TRIGGER IF NOT EXISTS set_calendar_events_updated_at
AFTER UPDATE ON calendar_events FOR EACH ROW BEGIN
  UPDATE calendar_events SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_pricebooks_updated_at
AFTER UPDATE ON pricebooks FOR EACH ROW BEGIN
  UPDATE pricebooks SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_products_updated_at
AFTER UPDATE ON products FOR EACH ROW BEGIN
  UPDATE products SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_locations_updated_at
AFTER UPDATE ON locations FOR EACH ROW BEGIN
  UPDATE locations SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_product_items_updated_at
AFTER UPDATE ON product_items FOR EACH ROW BEGIN
  UPDATE product_items SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_pricebook_entries_updated_at
AFTER UPDATE ON pricebook_entries FOR EACH ROW BEGIN
  UPDATE pricebook_entries SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_job_line_items_updated_at
AFTER UPDATE ON job_line_items FOR EACH ROW BEGIN
  UPDATE job_line_items SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_quotes_updated_at
AFTER UPDATE ON quotes FOR EACH ROW BEGIN
  UPDATE quotes SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_object_feeds_updated_at
AFTER UPDATE ON object_feeds FOR EACH ROW BEGIN
  UPDATE object_feeds SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_invoices_updated_at
AFTER UPDATE ON invoices FOR EACH ROW BEGIN
  UPDATE invoices SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_invoice_line_items_updated_at
AFTER UPDATE ON invoice_line_items FOR EACH ROW BEGIN
  UPDATE invoice_line_items SET updated_at = datetime('now') WHERE id = OLD.id;
END;



CREATE TRIGGER IF NOT EXISTS set_object_metadata_updated_at
AFTER UPDATE ON object_metadata FOR EACH ROW BEGIN
  UPDATE object_metadata SET updated_at = datetime('now') WHERE id = OLD.id;
END;

CREATE TRIGGER IF NOT EXISTS set_layout_definitions_updated_at
AFTER UPDATE ON layout_definitions FOR EACH ROW BEGIN
  UPDATE layout_definitions SET updated_at = datetime('now') WHERE id = OLD.id;
END;