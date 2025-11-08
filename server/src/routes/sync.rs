use axum::{http::HeaderMap, http::StatusCode, response::IntoResponse, Json, extract::{Query, State}};
use chrono::{SecondsFormat, Utc};
use rusqlite::{Connection, Result, params};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::sync::{Arc, Mutex};
// NOTE: This requires the `sha2` crate. Add `sha2 = "0.10"` to Cargo.toml.
use sha2::{Sha256, Digest};

use crate::models::*;

use super::data_result;

// When a tenant has no previous changes, we use a known "genesis" hash
// as the starting point for the hash chain. This ensures the chain is always
// valid and verifiable from the very first entry.
const GENESIS_HASH: &str = "0000000000000000000000000000000000000000000000000000000000000000"; // 64 zeros

// Shared state (same as in main.rs)
#[derive(Clone)]
pub struct AppState {
    pub db: Arc<Mutex<Connection>>,
}

/// Apply a change to the jobs table with upsert semantics for client-generated IDs.
/// - UPDATE merges the JSON patch; if no row exists, INSERT a new record.
fn apply_job_change(
    tx: &rusqlite::Transaction,
    overlay: &OverlayRecord,
    user_id: &str,
    changes_json: &str,
) -> rusqlite::Result<()> {
    let updated = tx.execute(
        "UPDATE jobs SET data = json_patch(data, ?1), version = version + 1, updated_at = ?2 WHERE id = ?3",
        params![changes_json, overlay.created_at, overlay.object_id],
    )?;

    if updated == 0 {
        // No existing row; treat as CREATE and insert a new record.
        tx.execute(
            "INSERT INTO jobs (id, tenant_id, status, version, created_by, modified_by, created_at, updated_at, object_name, object_type, data) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9, ?10, ?11)",
            params![
                overlay.object_id,   // id
                overlay.tenant_id,   // tenant_id
                "active",            // status (default for new records)
                0,                    // version
                user_id,              // created_by
                user_id,              // modified_by
                overlay.created_at,  // created_at
                overlay.created_at,  // updated_at
                overlay.object_name, // object_name
                overlay.object_name, // object_type (using object_name for now)
                changes_json,        // data (initial document)
            ],
        )?;
    }

    Ok(())
}

// Query params for GET /sync
#[derive(Deserialize)]
pub struct SyncParams {
    pub tenant_id: String,
    pub since: Option<String>,
}

// Main handler for GET /sync
pub async fn sync_handler(
    State(state): State<AppState>,
    Query(params): Query<SyncParams>,
) -> impl IntoResponse {
    let now = Utc::now().to_rfc3339_opts(SecondsFormat::Secs, true);
    let since = params.since.unwrap_or_else(|| "1970-01-01T00:00:00Z".to_string());

    let conn = state.db.lock().unwrap();

    let data_result = data_result::get_data_result(&conn, &params.tenant_id, &since);

    match data_result {
        Ok(data) => {
            let response = SyncResponse {
                meta: Meta {
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

// Struct for deserializing incoming overlay records from the client
#[derive(Deserialize)]
pub struct OverlayRecord {
    pub id: String,
    pub tenant_id: String,
    pub object_id: String,
    pub object_name: String,
    pub changes: Value,
    pub created_at: String,
    pub state_hash: String, // The client-calculated hash for this change
    pub previous_state_hash: String, // The hash this change is based on
}

/// Handler for POST /sync
///
/// Accepts a batch of client overlays (local diffs) and appends them to the
/// server's hash‑chained, append‑only `change_log` for a tenant.
///
/// Chain rules (per tenant_id):
/// - Each item carries `previous_state_hash`, which must equal the server's
///   current head for the tenant at the time of processing.
/// - The server recomputes the content hash using the exact same tuple the
///   client used, then hashes it with `previous_state_hash` to derive
///   `state_hash`. This must match the client's `state_hash`.
/// - On success, the server appends the row, updates the domain record, and
///   advances the head; processing continues for the next item in the batch.
pub async fn post_sync_handler(
    State(state): State<AppState>,
    headers: HeaderMap,
    Json(overlays): Json<Vec<OverlayRecord>>,
) -> impl IntoResponse {
    // Fast path: nothing to do.
    if overlays.is_empty() {
        return (StatusCode::OK, Json(json!({ "status": "ok", "message": "No changes to sync." }))).into_response();
    }

    // Serialize access to the DB (SQLite) with a mutex guard.
    let mut conn = state.db.lock().unwrap();

    // FAKE AUTH: Extract user ID from a header (to be replaced by real auth).
    let user_id = headers
        .get("X-User-ID")
        .and_then(|header| header.to_str().ok())
        .unwrap_or("fake_user_from_header"); // Default for development

    // Start a transaction to ensure atomicity of the batch.
    let tx = match conn.transaction() {
        Ok(tx) => tx,
        Err(e) => return (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({ "status": "error", "message": e.to_string() }))).into_response(),
    };

    // --- Preflight: Validate tenant and user exist to avoid opaque FK errors ---
    // Validate tenant exists
    let tenant_check: Result<i64, _> = tx.query_row(
        "SELECT COUNT(1) FROM tenants WHERE id = ?1",
        params![&overlays[0].tenant_id],
        |row| row.get(0),
    );
    if let Ok(count) = tenant_check {
        if count == 0 {
            return (StatusCode::BAD_REQUEST, Json(json!({
                "status": "error",
                "error": "invalid_tenant",
                "message": "Provided tenant_id does not exist.",
                "details": { "tenant_id": overlays[0].tenant_id }
            }))).into_response();
        }
    }

    // Validate user exists (required by change_log.user_id FK)
    let user_check: Result<i64, _> = tx.query_row(
        "SELECT COUNT(1) FROM users WHERE id = ?1",
        params![user_id],
        |row| row.get(0),
    );
    if let Ok(count) = user_check {
        if count == 0 {
            return (StatusCode::BAD_REQUEST, Json(json!({
                "status": "error",
                "error": "invalid_user",
                "message": "X-User-ID does not refer to an existing user.",
                "details": { "user_id": user_id }
            }))).into_response();
        }
    }

    // --- Batch Validation Step 1: Verify the chain's starting point ---
    // Get the server's latest hash just once for this tenant.
    let server_latest_hash_result: Result<String, _> = tx.query_row(
        "SELECT state_hash FROM change_log WHERE tenant_id = ?1 ORDER BY sequence_id DESC LIMIT 1",
        params![&overlays[0].tenant_id],
        |row| row.get(0),
    );
    let mut current_chain_head = server_latest_hash_result.unwrap_or(GENESIS_HASH.to_string());

    for overlay in overlays {
        // Optionally constrain which objects are handled. Others are currently skipped.
        if overlay.object_name != "job" { continue; }

        // --- Validation Step 2: Verify each link in the chain ---
        if overlay.previous_state_hash != current_chain_head {
            return (StatusCode::CONFLICT, Json(json!({
                "status": "error",
                "message": "Client history has diverged or batch is inconsistent. Please sync first."
            }))).into_response();
        }

        // --- Validation Step 3: Verify the Content ---
        // Serialize the JSON as a minified string (serde_json's to_string). This must match the
        // client's canonicalization strategy.
        let changes_json = overlay.changes.to_string();

        // Recompute client content hash.
        let change_to_hash = format!(
            "{}{}{}{}{}{}{}",
            overlay.id,
            overlay.tenant_id,
            user_id, // Using the user_id from the header
            overlay.created_at,
            overlay.object_name,
            overlay.object_id,
            changes_json
        );
        let mut hasher = Sha256::new();
        hasher.update(change_to_hash.as_bytes());
        let change_hash = format!("{:x}", hasher.finalize());
        // Combine with previous_state_hash to compute the new state hash.
        let combined_hash_data = format!("{}{}", change_hash, overlay.previous_state_hash);
        let mut final_hasher = Sha256::new();
        final_hasher.update(combined_hash_data.as_bytes());
        let server_calculated_hash = format!("{:x}", final_hasher.finalize());

        if server_calculated_hash != overlay.state_hash {
            // Provide detailed mismatch context for debugging client/server hashing.
            return (StatusCode::BAD_REQUEST, Json(json!({
                "status": "error",
                "error": "hash_mismatch",
                "message": "Client hash does not match server calculation.",
                "details": {
                    "tenant_id": overlay.tenant_id,
                    "object_name": overlay.object_name,
                    "object_id": overlay.object_id,
                    "created_at": overlay.created_at,
                    "user_id": user_id,
                    "previous_state_hash": overlay.previous_state_hash,
                    "client_state_hash": overlay.state_hash,
                    "server_state_hash": server_calculated_hash,
                    "server_change_hash": change_hash,
                    // Echo back the exact JSON string we hashed on the server side
                    "server_changes_json": changes_json,
                }
            }))).into_response();
        }
        // --- End of Validation ---

        // --- Persist the Change ---
        // Note: we do not insert the sequence_id, it's an auto-incrementing primary key.
        let change_log_result = tx.execute(
            "INSERT INTO change_log (id, tenant_id, user_id, object_name, record_id, change_data, state_hash, previous_state_hash, created_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7, ?8, ?9)",
            params![
                &overlay.id,
                &overlay.tenant_id,
                user_id,
                &overlay.object_name,
                &overlay.object_id,
                &changes_json,
                &overlay.state_hash, // Persist the verified hash from the client
                &overlay.previous_state_hash,
                &overlay.created_at,
            ],
        );
        
        if let Err(e) = change_log_result {
            return (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({
                "status": "error",
                "error": "change_log_insert_failed",
                "message": "Failed to insert into change_log.",
                "details": { "sqlite_error": e.to_string() }
            }))).into_response();
        }

        // Apply the change to the jobs table (upsert semantics for client-generated IDs).
        if let Err(e) = apply_job_change(&tx, &overlay, user_id, &changes_json) {
            return (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({
                "status": "error",
                "error": "domain_apply_failed",
                "message": "Failed to apply change to domain table.",
                "details": { "sqlite_error": e.to_string(), "object_name": overlay.object_name }
            }))).into_response();
        }

        // --- Update the head of the chain for the next iteration ---
        current_chain_head = overlay.state_hash.clone();
    }

    if let Err(e) = tx.commit() {
        return (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({ "status": "error", "message": e.to_string() }))).into_response();
    }

    (StatusCode::OK, Json(json!({ "status": "ok" }))).into_response()
}


// --- V2 Sync Pull ---

#[derive(Deserialize)]
pub struct SyncParamsV2 {
    pub tenant_id: String,
    pub since_hash: Option<String>,
}

#[derive(Serialize)]
pub struct ChangeLogRecord {
    pub sequence_id: i64,
    pub id: String,
    pub tenant_id: String,
    pub user_id: String,
    pub object_name: String,
    pub record_id: String,
    pub change_data: Value,
    pub state_hash: String,
    pub previous_state_hash: String,
    pub created_at: String,
}

// V2 delta pull endpoint for a hash‑chained, append‑only change log.
//
// High‑level:
// - Clients track the last applied `state_hash` and pass it as `since_hash`.
// - We resolve that hash to a monotonic `sequence_id` and return all rows with
//   `sequence_id > anchor` for this tenant, ordered ASC.
// - Each row carries `state_hash` and `previous_state_hash` so the client can
//   verify the hash chain while applying changes.
pub async fn sync_handler_v2(
    State(state): State<AppState>,
    Query(params): Query<SyncParamsV2>,
) -> impl IntoResponse {
    // Get a connection guard. SQLite is used behind a Mutex for safe access.
    let conn = state.db.lock().unwrap();

    // Require an anchor hash. `Option` pattern‑match: if None, return 400.
    let Some(since_hash) = params.since_hash else {
        return (StatusCode::BAD_REQUEST, Json(json!({
            "error": "bootstrap_required",
            "message": "No since_hash provided. New clients must use the bootstrap endpoint."
        }))).into_response();
    };

    // Find the anchor `sequence_id` for (tenant_id, since_hash).
    // `query_row` returns a `Result<T, rusqlite::Error>`.
    let since_sequence_id_result: Result<i64, _> = conn.query_row(
        "SELECT sequence_id FROM change_log WHERE state_hash = ?1 AND tenant_id = ?2",
        params![&since_hash, &params.tenant_id],
        |row| row.get(0),
    );

    // Require a successful lookup. If the hash is unknown, ask the client to bootstrap.
    let Ok(since_sequence_id) = since_sequence_id_result else {
        return (StatusCode::BAD_REQUEST, Json(json!({
            "error": "bootstrap_required",
            "message": "Provided since_hash not found. Client may be too old and must perform a new bootstrap sync."
        }))).into_response();
    };

    // Map a result row to our API model. `row.get::<_, T>(index)` extracts a typed column by index.
    let map_change_row = |row: &rusqlite::Row| -> rusqlite::Result<ChangeLogRecord> {
        let change_data_str: String = row.get(6)?;
        Ok(ChangeLogRecord {
            sequence_id: row.get(0)?,
            id: row.get(1)?,
            tenant_id: row.get(2)?,
            user_id: row.get(3)?,
            object_name: row.get(4)?,
            record_id: row.get(5)?,
            // Parse JSON payload; if parsing fails, use JSON null to keep the stream resilient.
            change_data: serde_json::from_str(&change_data_str).unwrap_or(json!(null)),
            state_hash: row.get(7)?,
            previous_state_hash: row.get(8)?,
            created_at: row.get(9)?,
        })
    };

    // Prepare and execute the delta query:
    // - Only rows for this tenant
    // - Strictly after the anchor (sequence_id > since_sequence_id)
    // - Ordered ASC for safe sequential application
    let mut stmt = conn.prepare(
        "SELECT sequence_id, id, tenant_id, user_id, object_name, record_id, change_data, state_hash, previous_state_hash, created_at FROM change_log WHERE tenant_id = ?1 AND sequence_id > ?2 ORDER BY sequence_id ASC"
    ).unwrap();

    // Execute and map rows. We avoid the `?` operator inside async by chaining `and_then`.
    let changes_result: Result<Vec<ChangeLogRecord>, rusqlite::Error> = stmt
        .query_map(params![params.tenant_id, since_sequence_id], map_change_row)
        .and_then(|rows| rows.collect());

    match changes_result {
        // Success → 200 with the list of deltas.
        Ok(changes) => {
            (StatusCode::OK, Json(changes)).into_response()
        }
        // SQL/mapping error → 500 with a simple message.
        Err(e) => {
            (StatusCode::INTERNAL_SERVER_ERROR, Json(json!({ "status": "error", "message": e.to_string() }))).into_response()
        }
    }
}
