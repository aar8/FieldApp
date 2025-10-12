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
use rusqlite::Connection;

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
    pub tenants: Vec<serde_json::Value>,
    pub object_metadata: Vec<serde_json::Value>,
    pub layouts: Vec<serde_json::Value>,
    pub customers: Vec<serde_json::Value>,
    pub jobs: Vec<serde_json::Value>,
    pub devices: Vec<serde_json::Value>,
}

#[derive(Serialize)]
pub struct SyncResponse {
    pub meta: SyncMeta,
    pub data: SyncData,
}

// Main handler for GET /sync
pub async fn sync_handler(
    State(_state): State<AppState>,
    Query(params): Query<SyncParams>,
) -> impl IntoResponse {
    let now = Utc::now().to_rfc3339();
    let since = params.since.unwrap_or_else(|| "1970-01-01T00:00:00Z".to_string());

    // Mock payload for now
    let mock_job = serde_json::json!({
        "id": "job-001",
        "tenant_id": params.tenant_id,
        "object_type": "job",
        "status": "scheduled",
        "data": { "title": "Fix HVAC Unit", "priority": "High" },
        "version": 1,
        "created_at": now,
        "updated_at": now
    });

    let mock_customer = serde_json::json!({
        "id": "cust-001",
        "tenant_id": params.tenant_id,
        "object_type": "customer",
        "status": "active",
        "data": { "name": "ACME Corp", "contact": "John Doe" },
        "version": 2,
        "created_at": now,
        "updated_at": now
    });

    let data = SyncData {
        tenants: vec![],
        object_metadata: vec![],
        layouts: vec![],
        customers: vec![mock_customer],
        jobs: vec![mock_job],
        devices: vec![],
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