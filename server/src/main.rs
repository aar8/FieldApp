use axum::{
    routing::{get, post},
    response::IntoResponse,
    Json, Router,
};
use serde_json::json;
use rusqlite::Connection;
use std::net::SocketAddr;
use std::sync::{Arc, Mutex};

pub mod models;
pub mod fetching;
mod routes;
use routes::sync::{sync_handler, post_sync_handler, sync_handler_v2, AppState};

#[tokio::main]
async fn main() {
    println!("Starting FieldPrime (Axum) server on port 8080...");

    // Shared SQLite connection state
    let conn = Connection::open("/app/data/fieldprime.db").expect("Failed to open SQLite DB");
    let state = AppState { db: Arc::new(Mutex::new(conn)) };

    // Build router with shared state
    let app = Router::new()
        .route("/health", get(health))
        .route("/sync", get(sync_handler))
        .route("/sync", post(post_sync_handler))
        .route("/sync/v2", get(sync_handler_v2))
        .with_state(state);

    // Start server
    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("Listening on {}", addr);
    axum::serve(tokio::net::TcpListener::bind(addr).await.unwrap(), app)
        .await
        .unwrap();
}

async fn health() -> impl IntoResponse {
    let result = check_db();
    match result {
        Ok(_) => Json(json!({
            "status": "ok",
            "sqlite_connected": true
        })),
        Err(e) => Json(json!({
            "status": "ok",
            "sqlite_connected": false,
            "error": e.to_string()
        })),
    }
}

fn check_db() -> Result<bool, rusqlite::Error> {
    let conn = Connection::open("/app/data/fieldprime.db")?;
    let _: i64 = conn.query_row("select count(*) from tenants;", [], |row| row.get(0))?;
    Ok(true)
}