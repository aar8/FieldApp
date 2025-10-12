use chrono::{Duration, Utc};
use fake::{
    faker::{
        company::en::{Bs, CatchPhrase, CompanyName},
        internet::en::SafeEmail,
        name::en::Name,
    },
    Fake,
};
use rand::seq::SliceRandom;
use rand::Rng;
use rusqlite::{params, Connection};
use serde_json::json;
use uuid::Uuid;

const TENANTS: usize = 500;
const USERS_PER_TENANT: usize = 10;
const CUSTOMERS_PER_TENANT: usize = 100; // 500 * 100 = 50,000
const JOBS_PER_TENANT: usize = 500; // 500 * 500 = 250,000
const SERVICES_TOTAL: usize = 2500;
const DEVICES_TOTAL: usize = 2000;

fn get_variable_datetime() -> String {
    let now = Utc::now();
    let mut rng = rand::thread_rng();

    // Define time offsets for seeding
    let offsets = [
        Duration::zero(),
        Duration::hours(1),
        Duration::days(1),
        Duration::days(2),
        Duration::days(3),
        Duration::weeks(1),
        Duration::days(30), // Approx 1 month
        Duration::days(60), // Approx 2 months
    ];

    let offset = offsets.choose(&mut rng).map(|d| *d).unwrap_or(Duration::zero());
    let dt = now - offset;
    // Format for SQLite DATETIME
    dt.to_rfc3339()
}

pub fn seed_db(conn: &mut Connection) -> rusqlite::Result<()> {
    let txn = conn.transaction()?;

    let mut tenant_ids = Vec::with_capacity(TENANTS);
    println!("🌱 Seeding tenants...");
    for _ in 0..TENANTS {
        let id = format!("tnt_{}", Uuid::new_v4().simple());
        let schema = json!({
            "name": CompanyName().fake::<String>(),
            "plan": "pro",
            "settings": { "timezone": "America/Chicago" }
        })
        .to_string();
        let timestamp = get_variable_datetime();

        txn.execute(
            "INSERT INTO tenants (id, schema, created_by, created_at, updated_at) VALUES (?1, ?2, 'seed', ?3, ?4)",
            params![id, schema, timestamp, timestamp],
        )?;
        tenant_ids.push(id);
    }

    let mut user_ids_by_tenant: Vec<(String, Vec<String>)> = Vec::with_capacity(TENANTS);
    println!("🌱 Seeding users...");
    for tenant_id in &tenant_ids {
        let mut user_ids = Vec::with_capacity(USERS_PER_TENANT);
        for i in 0..USERS_PER_TENANT {
            let user_id = format!("usr_{}", Uuid::new_v4().simple());
            let data = json!({
                "name": Name().fake::<String>(),
                "email": SafeEmail().fake::<String>(),
                "role": if i == 0 { "dispatcher" } else { "tech" }
            })
            .to_string();
            let timestamp = get_variable_datetime();

            txn.execute(
                "INSERT INTO users (id, tenant_id, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
                params![user_id, tenant_id, data, timestamp, timestamp],
            )?;
            user_ids.push(user_id);
        }
        user_ids_by_tenant.push((tenant_id.clone(), user_ids));
    }

    let mut customer_ids_by_tenant: Vec<(String, Vec<String>)> = Vec::with_capacity(TENANTS);
    println!("🌱 Seeding customers...");
    for tenant_id in &tenant_ids {
        let mut customer_ids = Vec::with_capacity(CUSTOMERS_PER_TENANT);
        for _ in 0..CUSTOMERS_PER_TENANT {
            let customer_id = format!("cus_{}", Uuid::new_v4().simple());
            let data = json!({
                "name": Name().fake::<String>(),
                "contact": {
                    "email": SafeEmail().fake::<String>(),
                    "phone": "555-123-4567"
                },
                "address": {
                    "street": "123 Main St",
                    "city": "Anytown",
                    "state": "CA",
                    "zip": "12345"
                }
            })
            .to_string();
            let timestamp = get_variable_datetime();
            txn.execute(
                "INSERT INTO customers (id, tenant_id, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
                params![customer_id, tenant_id, data, timestamp, timestamp],
            )?;
            customer_ids.push(customer_id);
        }
        customer_ids_by_tenant.push((tenant_id.clone(), customer_ids));
    }

    println!("🌱 Seeding jobs...");
    let job_statuses = ["scheduled", "in_progress", "completed", "cancelled"];
    for (tenant_id, user_ids) in &user_ids_by_tenant {
        let customers = customer_ids_by_tenant
            .iter()
            .find(|(t, _)| t == tenant_id)
            .unwrap();
        for _ in 0..JOBS_PER_TENANT {
            let job_id = format!("job_{}", Uuid::new_v4().simple());
            let customer_id = customers.1.choose(&mut rand::thread_rng()).unwrap();
            let assigned_to = user_ids.choose(&mut rand::thread_rng()).unwrap();
            let status = job_statuses.choose(&mut rand::thread_rng()).unwrap();

            let data = json!({
                "customer_id": customer_id,
                "assigned_to": assigned_to,
                "notes": CatchPhrase().fake::<String>(),
                "custom_fields": {
                    "priority": "high"
                }
            })
            .to_string();
            let timestamp = get_variable_datetime();

            txn.execute(
                "INSERT INTO jobs (id, tenant_id, status, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
                params![job_id, tenant_id, status, data, timestamp, timestamp],
            )?;
        }
    }

    println!("🌱 Seeding services...");
    for _ in 0..SERVICES_TOTAL {
        let service_id = format!("svc_{}", Uuid::new_v4().simple());
        let tenant_id = tenant_ids.choose(&mut rand::thread_rng()).unwrap();
        let data = json!({
            "name": Bs().fake::<String>(),
            "category": "General",
            "cost": rand::thread_rng().gen_range(50.0..500.0)
        })
        .to_string();
        let timestamp = get_variable_datetime();
        txn.execute(
            "INSERT INTO services (id, tenant_id, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
            params![service_id, tenant_id, data, timestamp, timestamp],
        )?;
    }

    println!("🌱 Seeding pricebooks, layouts, and metadata...");
    for tenant_id in &tenant_ids {
        let timestamp = get_variable_datetime();
        // Pricebooks
        let pricebook_id = format!("pb_{}", Uuid::new_v4().simple());
        let pricebook_data = json!({ "name": "Standard Pricebook", "currency": "USD" }).to_string();
        txn.execute(
            "INSERT INTO pricebooks (id, tenant_id, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
            params![pricebook_id, tenant_id, pricebook_data, timestamp, timestamp],
        )?;

        // Layout Definitions
        let layout_id = format!("lyt_{}", Uuid::new_v4().simple());
        let layout_data = json!({
            "sections": [
                { "label": "Job Info", "fields": ["title", "customer", "priority"] },
                { "label": "Scheduling", "fields": ["scheduled_date"] }
            ]
        })
        .to_string();
        txn.execute(
            "INSERT INTO layout_definitions (id, tenant_id, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'job', ?3, ?4, ?5)",
            params![layout_id, tenant_id, layout_data, timestamp, timestamp],
        )?;

        // Object Metadata
        let meta_id = format!("meta_{}", Uuid::new_v4().simple());
        let meta_data = json!([
            { "name": "title", "label": "Job Title", "type": "string", "required": true },
            { "name": "customer", "label": "Customer", "type": "reference", "target_object": "customer" }
        ])
        .to_string();
        txn.execute(
            "INSERT INTO object_metadata (id, tenant_id, object_type, data, created_at, updated_at) VALUES (?1, ?2, 'job', ?3, ?4, ?5)",
            params![meta_id, tenant_id, meta_data, timestamp, timestamp],
        )?;
    }

    println!("🌱 Seeding devices...");
    let all_user_ids: Vec<String> = user_ids_by_tenant
        .iter()
        .flat_map(|(_, u)| u.clone())
        .collect();
    let platforms = ["ios", "android", "web"];
    for _ in 0..DEVICES_TOTAL {
        let device_id = format!("dev_{}", Uuid::new_v4().simple());
        let tenant_id = tenant_ids.choose(&mut rand::thread_rng()).unwrap();
        let user_id = all_user_ids.choose(&mut rand::thread_rng()).unwrap();
        let platform = platforms.choose(&mut rand::thread_rng()).unwrap();
        let timestamp = get_variable_datetime();
        let data = json!({
            "user_id": user_id,
            "platform": platform,
            "app_version": "1.2.3",
            "last_seen": "2025-10-26T10:00:00Z",
            "revoked": false
        })
        .to_string();
        txn.execute(
            "INSERT INTO devices (id, tenant_id, data, created_at, updated_at) VALUES (?1, ?2, ?3, ?4, ?5)",
            params![device_id, tenant_id, data, timestamp, timestamp],
        )?;
    }

    println!("✅ Committing changes...");
    txn.commit()?;
    Ok(())
}
