// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

use rusqlite::{Connection, Result};
use crate::models::*;
use crate::fetching::fetch_all;


pub fn get_data_result(conn: &Connection, tenant_id: &str, since: &str) -> Result<ResponseData> {
    Ok(ResponseData {
        users: fetch_all(&conn, "users", tenant_id, since, crate::models::user_record_from_row)?,
        customers: fetch_all(&conn, "customers", tenant_id, since, crate::models::customer_record_from_row)?,
        jobs: fetch_all(&conn, "jobs", tenant_id, since, crate::models::job_record_from_row)?,
        calendar_events: fetch_all(&conn, "calendar_events", tenant_id, since, crate::models::calendar_event_record_from_row)?,
        pricebooks: fetch_all(&conn, "pricebooks", tenant_id, since, crate::models::pricebook_record_from_row)?,
        products: fetch_all(&conn, "products", tenant_id, since, crate::models::product_record_from_row)?,
        locations: fetch_all(&conn, "locations", tenant_id, since, crate::models::location_record_from_row)?,
        product_items: fetch_all(&conn, "product_items", tenant_id, since, crate::models::product_item_record_from_row)?,
        pricebook_entries: fetch_all(&conn, "pricebook_entries", tenant_id, since, crate::models::pricebook_entry_record_from_row)?,
        job_line_items: fetch_all(&conn, "job_line_items", tenant_id, since, crate::models::job_line_item_record_from_row)?,
        quotes: fetch_all(&conn, "quotes", tenant_id, since, crate::models::quote_record_from_row)?,
        object_feeds: fetch_all(&conn, "object_feeds", tenant_id, since, crate::models::object_feed_record_from_row)?,
        invoices: fetch_all(&conn, "invoices", tenant_id, since, crate::models::invoice_record_from_row)?,
        invoice_line_items: fetch_all(&conn, "invoice_line_items", tenant_id, since, crate::models::invoice_line_item_record_from_row)?,
        object_metadata: fetch_all(&conn, "object_metadata", tenant_id, since, crate::models::object_metadata_record_from_row)?,
        layout_definitions: fetch_all(&conn, "layout_definitions", tenant_id, since, crate::models::layout_definition_record_from_row)?,
    })
}