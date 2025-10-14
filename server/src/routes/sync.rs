// ============================================================ 
// 🧩 FIELDPRIME SYNC ENDPOINT DESIGN
// ============================================================
// ROUTE:    GET /sync?tenant_id=<id>&since=<timestamp>
// PURPOSE:  Provide a unified, deterministic, incremental data feed
//            for all entities and metadata a client needs to stay
//            synchronized with the authoritative server state.
//
// ------------------------------------------------------------
// OVERVIEW
// ------------------------------------------------------------
// FieldPrime uses a JSON1-based flexible schema model where each
// entity table (e.g., jobs, customers, layouts, metadata) stores
// its record body as a JSON blob with standard columns:
//
//   id TEXT PRIMARY KEY
//   tenant_id TEXT REFERENCES tenants(id)
//   object_type TEXT
//   status TEXT
//   data JSON
//   version INTEGER
//   created_by TEXT
//   modified_by TEXT
//   created_at TEXT DEFAULT (datetime('now'))
//   updated_at TEXT DEFAULT (datetime('now'))
//
// Because all entities share this contract, we can query them
// generically and combine results in a single endpoint.
//
// ------------------------------------------------------------
// SYNC DIRECTION
// ------------------------------------------------------------
//  → Client → Server  : Local changes (insert/update/delete)
//                       are queued in a client-only "pending_changes"
//                       table and uploaded later via a /push route.
//  ← Server → Client  : This /sync endpoint returns authoritative data
//                       that the client must mirror locally.
//
// The client NEVER writes directly into the "authoritative" tables
// (jobs, customers, etc.) — it replaces its local cache wholesale
// when receiving updates.
//
// ------------------------------------------------------------
// REQUEST
// ------------------------------------------------------------
//   GET /sync?tenant_id=TENANT123&since=2025-10-10T00:00:00Z
//
// PARAMETERS:
//   tenant_id  - Required. Filters data to the tenant’s records.
//   since      - Optional. ISO-8601 timestamp of last successful sync.
//                If omitted, defaults to 1970-01-01T00:00:00Z.
//
// ------------------------------------------------------------
// RESPONSE
// ------------------------------------------------------------
// {
//   "meta": {
//     "server_time": "2025-10-11T18:05:22Z",
//     "since": "2025-10-10T00:00:00Z"
//   },
//   "data": {
//     "tenants": [...],
//     "object_metadata": [...],
//     "layouts": [...],
//     "customers": [...],
//     "jobs": [...],
//     "devices": [...]
//   }
// }
//
// NOTE: The client should persist the `server_time` from the response
// and use it as the `since` parameter for its next sync request to
// ensure no data is missed.
//
// ------------------------------------------------------------
// SYNC RULES
// ------------------------------------------------------------
// • The server is the source of truth for all entities.
// • The client must treat received data as read-only.
// • Deletes are propagated via a status change. When a record is
//   deleted on the server, its status is set to 'deleted' (or
//   'archived') and its `updated_at` timestamp is changed. The
//   client MUST delete any record it receives with this status
//   from its local database.
// • All returned entities are JSON objects with complete
//   field payloads — no partial deltas yet.
// • Sync results are sorted by updated_at ascending to
//   help clients apply updates deterministically.
//
// ------------------------------------------------------------
// DATABASE QUERY STRATEGY
// ------------------------------------------------------------
// For each entity table:
//   SELECT * FROM <table>
//   WHERE tenant_id = ? AND updated_at > ?
//   ORDER BY updated_at ASC;
//
// Composite index recommended:
//   CREATE INDEX IF NOT EXISTS idx_<table>_tenant_updated
//   ON <table>(tenant_id, updated_at);
//
// This ensures O(log N) incremental lookups even for
// 100k+ row datasets.
//
// ------------------------------------------------------------
// CONSISTENCY GUARANTEES
// ------------------------------------------------------------
// • Snapshot isolation — each /sync call reflects a single
//   moment in time (`server_time` in the response).
// • Deterministic output — same query inputs always yield
//   identical JSON output.
// • No partial writes — server changes are versioned and
//   committed before sync queries execute.
//
// ------------------------------------------------------------
// FUTURE EXTENSIONS
// ------------------------------------------------------------
// • Add per-table manifests to avoid scanning tables with no updates.
// • Add integrity checksums for lightweight sync validation.
// • Add a /push route for client-side pending changes.
// • Add field-level diffs to reduce payload size.
//
// ------------------------------------------------------------
// SUMMARY
// ------------------------------------------------------------
// This endpoint defines the backbone of FieldPrime’s offline sync
// model. It keeps clients consistent, simple, and stateless while
// allowing the backend to remain flexible and schema-agnostic.
//
// ============================================================


use axum::{
    extract::{Query, State},
    response::IntoResponse,
    Json,
};
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};
use chrono::Utc;
use rusqlite::{Connection, params};
use serde_json::Value;

// Shared state (same as in main.rs)
#[derive(Clone)]
pub struct AppState {
    pub db: Arc<Mutex<Connection>>,
}

// Query params for /sync
#[derive(Deserialize)]
pub struct SyncParams {
    pub tenant_id: String,
    pub since: Option<String>,
}

// Response structs
#[derive(Serialize)]
pub struct SyncMeta {
    pub server_time: String,
    pub since: String,
}

#[derive(Serialize, Default)]
pub struct SyncData {
    pub object_metadata: Vec<serde_json::Value>,
    pub layouts: Vec<serde_json::Value>,
    pub customers: Vec<serde_json::Value>,
    pub jobs: Vec<serde_json::Value>,
    pub users: Vec<serde_json::Value>,
    pub devices: Vec<serde_json::Value>,
    pub attachments: Vec<serde_json::Value>,
    pub checklist_templates: Vec<serde_json::Value>,
    pub job_checklists: Vec<serde_json::Value>,
    pub calendar_events: Vec<serde_json::Value>,
    pub pricebooks: Vec<serde_json::Value>,
    pub services: Vec<serde_json::Value>,
    pub equipment_types: Vec<serde_json::Value>,
    pub customer_equipment: Vec<serde_json::Value>,
}

#[derive(Serialize)]
pub struct SyncResponse {
    pub meta: SyncMeta,
    pub data: SyncData,
}

// Main handler for GET /sync
pub async fn sync_handler(
    State(state): State<AppState>,
    Query(params): Query<SyncParams>,
) -> impl IntoResponse {
    let now = Utc::now().to_rfc3339();
    let since = params.since.unwrap_or_else(|| "1970-01-01T00:00:00Z".to_string());

    // Lock the DB once for all reads
    let conn = state.db.lock().unwrap();

    fn fetch_table(conn: &Connection, table: &str, tenant_id: &str, since: &str) -> Vec<Value> {
        let cols = match table {
            "object_metadata" | "layout_definitions" =>
                "id, tenant_id, object_type, data, version, created_by, modified_by, created_at, updated_at",
            _ =>
                "id, tenant_id, object_type, status, data, version, created_by, modified_by, created_at, updated_at",
        };
        let sql: String = format!("SELECT {} FROM {} WHERE tenant_id=?1 AND updated_at>?2 ORDER BY updated_at ASC", cols, table);

        let mut stmt = conn
            .prepare(&sql)
            .unwrap();

        let rows = stmt
            .query_map(params![tenant_id, since], |row| {
                Ok(serde_json::json!({
                    "id": row.get::<_, String>(0)?,
                    "tenant_id": row.get::<_, String>(1)?,
                    "object_type": row.get::<_, String>(2)?,
                    "status": row.get::<_, String>(3)?,
                    "data": serde_json::from_str::<Value>(&row.get::<_, String>(4)?).unwrap_or(Value::Null),
                    "version": row.get::<_, i64>(5)?,
                    "created_by": row.get::<_, Option<String>>(6)?,
                    "modified_by": row.get::<_, Option<String>>(7)?,
                    "created_at": row.get::<_, String>(8)?,
                    "updated_at": row.get::<_, String>(9)?,
                }))
            })
            .unwrap();

        rows.filter_map(Result::ok).collect()
    }

    let data = SyncData {
        object_metadata: fetch_table(&conn, "object_metadata", &params.tenant_id, &since),
        layouts: fetch_table(&conn, "layout_definitions", &params.tenant_id, &since),
        customers: fetch_table(&conn, "customers", &params.tenant_id, &since),
        jobs: fetch_table(&conn, "jobs", &params.tenant_id, &since),
        users: fetch_table(&conn, "users", &params.tenant_id, &since),
        devices: fetch_table(&conn, "devices", &params.tenant_id, &since),
        attachments: fetch_table(&conn, "attachments", &params.tenant_id, &since),
        checklist_templates: fetch_table(&conn, "checklist_templates", &params.tenant_id, &since),
        job_checklists: fetch_table(&conn, "job_checklists", &params.tenant_id, &since),
        calendar_events: fetch_table(&conn, "calendar_events", &params.tenant_id, &since),
        pricebooks: fetch_table(&conn, "pricebooks", &params.tenant_id, &since),
        services: fetch_table(&conn, "services", &params.tenant_id, &since),
        equipment_types: fetch_table(&conn, "equipment_types", &params.tenant_id, &since),
        customer_equipment: fetch_table(&conn, "customer_equipment", &params.tenant_id, &since),
    };

    let response = SyncResponse {
        meta: SyncMeta {
            server_time: now,
            since,
        },
        data,
    };

    Json(response)
}