use axum::{
    extract::{Query, State},
    response::IntoResponse,
    Json,
};
use chrono::{SecondsFormat, Utc};
use rusqlite::{Connection, Result};
use serde::Deserialize;
use serde_json::json;
use std::sync::{Arc, Mutex};

use crate::models::*;
use crate::fetching::fetch_all;

use super::data_result;

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