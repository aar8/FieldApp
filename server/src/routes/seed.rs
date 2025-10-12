use axum::{Json, extract::State};
use rusqlite::Connection;
use serde_json::json;
use std::sync::{Arc, Mutex};

use super::seed_db;
use crate::AppState;

pub async fn seed_handler(
    State(state): State<AppState>
) -> Json<serde_json::Value> {
    let mut conn = state.db.lock().unwrap();

    match seed_db::seed_db(&mut conn) {
        Ok(_) => Json(json!({
            "status": "ok",
            "message": "Seed data inserted successfully"
        })),
        Err(e) => Json(json!({
            "status": "error",
            "error": e.to_string()
        })),
    }
}