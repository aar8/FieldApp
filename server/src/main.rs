use actix_web::{get, App, HttpResponse, HttpServer, Responder};
use rusqlite::Connection;

#[get("/health")]
async fn health() -> impl Responder {
    match check_db() {
        Ok(_) => HttpResponse::Ok().json(serde_json::json!({
            "status": "ok",
            "sqlite_connected": true
        })),
        Err(e) => HttpResponse::Ok().json(serde_json::json!({
            "status": "ok",
            "sqlite_connected": false,
            "error": e.to_string()
        })),
    }
}

fn check_db() -> Result<bool, rusqlite::Error> {
    let conn = Connection::open("/app/data/fieldprime.db")?;
    let _: i64 = conn.query_row("SELECT 1", [], |row| row.get(0))?;
    Ok(true)
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    println!("Starting FieldPrime server on port 8080...");
    HttpServer::new(|| App::new().service(health))
        .bind(("0.0.0.0", 8080))?
        .run()
        .await
}