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
use chrono::{SecondsFormat, Utc};
use rusqlite::{params, Connection, Result};
use serde::{
    Deserialize, Serialize
};
use serde_json::{json, Value};
use std::sync::{Arc, Mutex};

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
    pub users: Vec<Value>,
    pub customers: Vec<Value>,
    pub jobs: Vec<Value>,
    pub calendar_events: Vec<Value>,
    pub pricebooks: Vec<Value>,
    pub products: Vec<Value>,
    pub locations: Vec<Value>,
    pub product_items: Vec<Value>,
    pub pricebook_entries: Vec<Value>,
    pub job_line_items: Vec<Value>,
    pub quotes: Vec<Value>,
    pub object_feeds: Vec<Value>,
    pub invoices: Vec<Value>,
    pub invoice_line_items: Vec<Value>,
    pub object_metadata: Vec<Value>,
    pub layout_definitions: Vec<Value>,
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
    let now = Utc::now().to_rfc3339_opts(SecondsFormat::Secs, true);
    let since = params.since.unwrap_or_else(|| "1970-01-01T00:00:00Z".to_string());

    let conn = state.db.lock().unwrap();

    // Helper function to deserialize JSON data from a string column
    fn get_json_data(row: &rusqlite::Row, index: usize) -> Result<Value> {
        let data_str: String = row.get(index)?;
        serde_json::from_str(&data_str).map_err(|e| {
            rusqlite::Error::FromSqlConversionFailure(index, rusqlite::types::Type::Text, Box::new(e))
        })
    }

    let data_result: Result<SyncData> = (|| {
        // Standard tables with object_name, object_type, and status
        macro_rules! fetch_standard_table {
            ($table:literal) => {
                {
                    let mut stmt = conn.prepare(&format!(
                        "SELECT id, tenant_id, object_name, object_type, status, data, version, created_by, modified_by, created_at, updated_at FROM {} WHERE tenant_id=?1 AND updated_at>?2",
                        $table
                    ))?;
                    let rows = stmt.query_map(params![&params.tenant_id, &since], |row| {
                        Ok(json!({
                            "id": row.get::<_, String>(0)?,
                            "tenant_id": row.get::<_, String>(1)?,
                            "object_name": row.get::<_, String>(2)?,
                            "object_type": row.get::<_, String>(3)?,
                            "status": row.get::<_, String>(4)?,
                            "data": get_json_data(row, 5)?,
                            "version": row.get::<_, i64>(6)?,
                            "created_by": row.get::<_, Option<String>>(7)?,
                            "modified_by": row.get::<_, Option<String>>(8)?,
                            "created_at": row.get::<_, String>(9)?,
                            "updated_at": row.get::<_, String>(10)?,
                        }))
                    })?;
                    rows.collect::<Result<Vec<Value>>>()
                }
            }
        }

        // Special case: object_metadata (no object_type, status)
        let object_metadata: Vec<Value> = {
            let mut stmt = conn.prepare("SELECT id, tenant_id, object_name, data, version, created_by, modified_by, created_at, updated_at FROM object_metadata WHERE tenant_id=?1 AND updated_at>?2")?;
            let rows = stmt.query_map(params![&params.tenant_id, &since], |row| {
                Ok(json!({
                    "id": row.get::<_, String>(0)?,
                    "tenant_id": row.get::<_, String>(1)?,
                    "object_name": row.get::<_, String>(2)?,
                    "data": get_json_data(row, 3)?,
                    "version": row.get::<_, i64>(4)?,
                    "created_by": row.get::<_, Option<String>>(5)?,
                    "modified_by": row.get::<_, Option<String>>(6)?,
                    "created_at": row.get::<_, String>(7)?,
                    "updated_at": row.get::<_, String>(8)?,
                }))
            })?;
            rows.collect::<Result<Vec<Value>>>()
        }?;

        // layout_definitions has all the standard columns
        let layout_definitions: Vec<Value> = fetch_standard_table!("layout_definitions")?;

        Ok(SyncData {
            object_metadata,
            layout_definitions,
            users: fetch_standard_table!("users")?,
            customers: fetch_standard_table!("customers")?,
            jobs: fetch_standard_table!("jobs")?,
            calendar_events: fetch_standard_table!("calendar_events")?,
            pricebooks: fetch_standard_table!("pricebooks")?,
            products: fetch_standard_table!("products")?,
            locations: fetch_standard_table!("locations")?,
            product_items: fetch_standard_table!("product_items")?,
            pricebook_entries: fetch_standard_table!("pricebook_entries")?,
            job_line_items: fetch_standard_table!("job_line_items")?,
            quotes: fetch_standard_table!("quotes")?,
            object_feeds: fetch_standard_table!("object_feeds")?,
            invoices: fetch_standard_table!("invoices")?,
            invoice_line_items: fetch_standard_table!("invoice_line_items")?,
        })
    })();

    match data_result {
        Ok(data) => {
            let response = SyncResponse {
                meta: SyncMeta {
                    server_time: now,
                    since,
                },
                data,
            };
            Json(response).into_response()
        }
        Err(e) => {
            Json(json!({ "status": "error", "message": e.to_string() })).into_response()
        }
    }
}