PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'field-tech',
  object_type TEXT NOT NULL DEFAULT 'users',
  status TEXT NOT NULL DEFAULT 'active',
  version INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id)
);

CREATE TABLE IF NOT EXISTS customers (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  name TEXT NOT NULL,
  contact_email TEXT,
  phone TEXT,
  location TEXT,
  object_type TEXT NOT NULL DEFAULT 'customers',
  status TEXT NOT NULL DEFAULT 'active',
  version INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id)
);

CREATE TABLE IF NOT EXISTS jobs (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  customer_id TEXT NOT NULL,
  assigned_to TEXT,
  status TEXT NOT NULL DEFAULT 'scheduled',
  scheduled_start TEXT,
  scheduled_end TEXT,
  notes TEXT,
  object_type TEXT NOT NULL DEFAULT 'jobs',
  version INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, customer_id) REFERENCES customers(tenant_id, id) ON DELETE CASCADE,
  FOREIGN KEY (tenant_id, assigned_to) REFERENCES users(tenant_id, id)
);

CREATE TABLE IF NOT EXISTS job_events (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  job_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload TEXT,
  object_type TEXT NOT NULL DEFAULT 'job_events',
  status TEXT NOT NULL DEFAULT 'active',
  version INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, job_id) REFERENCES jobs(tenant_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS attachments (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  job_id TEXT,
  customer_id TEXT,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_size INTEGER NOT NULL,
  checksum TEXT,
  object_type TEXT NOT NULL DEFAULT 'attachments',
  status TEXT NOT NULL DEFAULT 'active',
  version INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, job_id) REFERENCES jobs(tenant_id, id) ON DELETE SET NULL,
  FOREIGN KEY (tenant_id, customer_id) REFERENCES customers(tenant_id, id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS object_metadata (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  api_name TEXT NOT NULL,
  label TEXT NOT NULL,
  plural_label TEXT NOT NULL,
  description TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  UNIQUE (tenant_id, api_name)
);

CREATE TABLE IF NOT EXISTS layouts (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  object_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  name TEXT NOT NULL,
  version INTEGER NOT NULL DEFAULT 1,
  is_default INTEGER NOT NULL DEFAULT 0,
  description TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, object_type) REFERENCES object_metadata(tenant_id, api_name) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS layout_sections (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  layout_id TEXT NOT NULL,
  name TEXT NOT NULL,
  order_index INTEGER NOT NULL,
  collapsible INTEGER NOT NULL DEFAULT 0,
  visibility_rule TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, layout_id) REFERENCES layouts(tenant_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS layout_fields (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  section_id TEXT NOT NULL,
  field_api_name TEXT NOT NULL,
  label_override TEXT,
  component TEXT NOT NULL DEFAULT 'text',
  order_index INTEGER NOT NULL,
  required INTEGER NOT NULL DEFAULT 0,
  readonly INTEGER NOT NULL DEFAULT 0,
  visible INTEGER NOT NULL DEFAULT 1,
  width_ratio REAL DEFAULT 1.0,
  default_value TEXT,
  validation_rule TEXT,
  help_text TEXT,
  show_if_rule TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, section_id) REFERENCES layout_sections(tenant_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS layout_assignments (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  layout_id TEXT NOT NULL,
  role TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id),
  FOREIGN KEY (tenant_id, layout_id) REFERENCES layouts(tenant_id, id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS sync_events (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  object_type TEXT NOT NULL,
  record_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  payload TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (tenant_id, id)
);

CREATE INDEX IF NOT EXISTS idx_users_tenant_id ON users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_customers_tenant_id ON customers(tenant_id);
CREATE INDEX IF NOT EXISTS idx_jobs_tenant_id ON jobs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_job_events_tenant_id ON job_events(tenant_id);
CREATE INDEX IF NOT EXISTS idx_attachments_tenant_id ON attachments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_object_metadata_tenant_id ON object_metadata(tenant_id);
CREATE INDEX IF NOT EXISTS idx_layouts_tenant_id ON layouts(tenant_id);
CREATE INDEX IF NOT EXISTS idx_layout_sections_tenant_id ON layout_sections(tenant_id);
CREATE INDEX IF NOT EXISTS idx_layout_fields_tenant_id ON layout_fields(tenant_id);
CREATE INDEX IF NOT EXISTS idx_layout_assignments_tenant_id ON layout_assignments(tenant_id);
CREATE INDEX IF NOT EXISTS idx_sync_events_tenant_id ON sync_events(tenant_id);

CREATE INDEX IF NOT EXISTS idx_jobs_customer_id ON jobs(customer_id);
CREATE INDEX IF NOT EXISTS idx_jobs_assigned_to ON jobs(assigned_to);
CREATE INDEX IF NOT EXISTS idx_job_events_job_id ON job_events(job_id);
CREATE INDEX IF NOT EXISTS idx_attachments_job_id ON attachments(job_id);
CREATE INDEX IF NOT EXISTS idx_attachments_customer_id ON attachments(customer_id);
CREATE INDEX IF NOT EXISTS idx_layouts_object_type_status ON layouts(object_type, status);
CREATE INDEX IF NOT EXISTS idx_sections_layout_id ON layout_sections(layout_id);
CREATE INDEX IF NOT EXISTS idx_fields_section_id ON layout_fields(section_id);
CREATE INDEX IF NOT EXISTS idx_layout_assignments_role ON layout_assignments(role);
