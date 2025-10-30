use axum::{extract::State, response::IntoResponse, Json};
use chrono::{SecondsFormat, Utc};
use fake::{
    faker::{
        company::en::CatchPhrase,
        internet::en::SafeEmail,
        name::en::Name,
    },
    Fake,
};
use rusqlite::{params, Connection};
use serde_json::json;
use uuid::Uuid;

use super::sync::AppState;

// This seeder creates the specific, foundational data required for the EPIC-1 MVP demo scenario to run,
// plus a few extra records for general testing purposes.

pub async fn seed_epic1_handler(State(state): State<AppState>) -> impl IntoResponse {
    println!("⚡️ Handling request to seed EPIC-1 scenario data...");
    let mut conn = state.db.lock().unwrap();
    match seed_epic1_db(&mut conn) {
        Ok(_) => Json(json!({ "status": "ok", "message": "EPIC-1 scenario seeded successfully." })),
        Err(e) => Json(json!({ "status": "error", "message": e.to_string() })),
    }
}

pub fn seed_epic1_db(conn: &mut Connection) -> rusqlite::Result<()> {
    let txn = conn.transaction()?;

    println!("🌱 Seeding foundational data for EPIC-1 MVP Scenario...");

    // 1. Create a single Tenant
    let tenant_id = "tnt_epic1_demo".to_string();
    let tenant_data = json!({
        "name": "FieldApp Demo Inc.",
        "plan": "premium"
    }).to_string();
    let timestamp = Utc::now().to_rfc3339_opts(SecondsFormat::Secs, true);

    txn.execute(
        "INSERT OR REPLACE INTO tenants (id, data, created_by, created_at, updated_at) VALUES (?1, ?2, 'seed', ?3, ?4)",
        params![tenant_id, tenant_data, timestamp, timestamp],
    )?;

    // 2. Create specific Users for the demo (Admin Sue and Tech Bob)
    let admin_user_id = "admin-sue".to_string();
    let tech_user_id = "tech-bob".to_string();

    let admin_data = json!({
        "display_name": "Sue (Admin)",
        "email": "sue@example.com",
        "role": "admin"
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO users (id, tenant_id, object_name, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'user', 'admin', ?3, ?4, ?5)",
        params![admin_user_id, tenant_id, admin_data, timestamp, timestamp],
    )?;

    let tech_data = json!({
        "display_name": "Tech Bob",
        "email": "bob@example.com",
        "role": "tech"
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO users (id, tenant_id, object_name, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'user', 'tech', ?3, ?4, ?5)",
        params![tech_user_id, tenant_id, tech_data, timestamp, timestamp],
    )?;

    // 3. Create the AC Tuneup service as a Product
    let product_id = "prod_ac_tuneup".to_string();
    let product_data = json!({
      "name": "AC Tuneup",
      "product_code": "SVC-TUNEUP-AC",
      "type": "service"
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO products (id, tenant_id, object_name, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'product', 'service', ?3, ?4, ?5)",
        params![product_id, tenant_id, product_data, timestamp, timestamp],
    )?;

    // 4. Create Object Metadata for the Job object
    let job_meta_id = "meta_job".to_string();
    let job_meta_data = json!({
        "field_definitions": [
            { "name": "job_number", "label": "Job #", "type": "string", "required": true },
            { "name": "customer_id", "label": "Customer", "type": "reference", "target_object": "customer", "required": true },
            { "name": "job_address", "label": "Job Address", "type": "string" },
            { "name": "job_description", "label": "Description", "type": "string" },
            { "name": "assigned_tech_id", "label": "Assigned Tech", "type": "reference", "target_object": "user" },
            { "name": "status_note", "label": "Status Note", "type": "string" },
            { "name": "quote_id", "label": "Quote", "type": "reference", "target_object": "quote" }
        ]
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO object_metadata (id, tenant_id, object_name, data, created_at, updated_at) VALUES (?1, ?2, 'job', ?3, ?4, ?5)",
        params![job_meta_id, tenant_id, job_meta_data, timestamp, timestamp],
    )?;

    // 5. Create Layout Definitions used in the scenario
    let scheduled_layout_id = "lyt_job_scheduled".to_string();
    let scheduled_layout_data = json!({
      "sections": [
        { "label": "Job Details", "fields": ["job_number", "job_description"] },
        { "label": "Customer", "fields": ["customer_id"] }
      ]
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO layout_definitions (id, tenant_id, object_name, object_type, status, data, created_at, updated_at) VALUES (?1, ?2, 'job', 'job_residential_tuneup', 'scheduled', ?3, ?4, ?5)",
        params![scheduled_layout_id, tenant_id, scheduled_layout_data, timestamp, timestamp],
    )?;

    let in_progress_layout_id = "lyt_job_in_progress".to_string();
    let in_progress_layout_data = json!({
        "sections": [
            { "label": "Work Checklist", "fields": ["line_item_1", "line_item_2"] }
        ]
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO layout_definitions (id, tenant_id, object_name, object_type, status, data, created_at, updated_at) VALUES (?1, ?2, 'job', 'job_residential_tuneup', 'in_progress', ?3, ?4, ?5)",
        params![in_progress_layout_id, tenant_id, in_progress_layout_data, timestamp, timestamp],
    )?;


    // 6. Add a few EXTRA records for general testing
    println!("🌱 Seeding extra records for sync testing...");

    // Extra Customer
    let extra_customer_id = "cus_extra_001".to_string();
    let extra_customer_data = json!({
        "name": Name().fake::<String>(),
        "contact": {
            "email": SafeEmail().fake::<String>(),
            "phone": "555-999-8888"
        }
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO customers (id, tenant_id, object_name, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'customer', 'residential', ?3, ?4, ?5)",
        params![extra_customer_id, tenant_id, extra_customer_data, timestamp, timestamp],
    )?;

    // Extra Tech User
    let extra_tech_id = "usr_extra_tech_002".to_string();
    let extra_tech_data = json!({
        "display_name": Name().fake::<String>(),
        "email": SafeEmail().fake::<String>(),
        "role": "tech"
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO users (id, tenant_id, object_name, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'user', 'tech', ?3, ?4, ?5)",
        params![extra_tech_id, tenant_id, extra_tech_data, timestamp, timestamp],
    )?;

    // Extra Job
    let extra_job_id = "job_extra_001".to_string();
    let extra_job_data = json!({
        "job_number": "J-EXTRA-1",
        "customer_id": extra_customer_id,
        "job_address": "456 Other St, Austin, TX 78704",
        "job_description": "Annual maintenance checkup.",
        "assigned_tech_id": extra_tech_id,
        "status_note": "Scheduled for next week."
    }).to_string();
    txn.execute(
        "INSERT OR REPLACE INTO jobs (id, tenant_id, object_name, object_type, status, data, created_at, updated_at) VALUES (?1, ?2, 'job', 'commercial', 'scheduled', ?3, ?4, ?5)",
        params![extra_job_id, tenant_id, extra_job_data, timestamp, timestamp],
    )?;


    println!("✅ Committing changes for EPIC-1 scenario...");
    txn.commit()?;
    Ok(())
}
