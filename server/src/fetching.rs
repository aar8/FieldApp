// This file contains generic data fetching logic.

use rusqlite::{Connection, Result, params};

pub fn fetch_all<T>(
    conn: &Connection,
    table_name: &str,
    tenant_id: &str,
    since: &str,
    decoder: fn(&rusqlite::Row) -> Result<T>
) -> Result<Vec<T>> {
    let mut stmt = conn.prepare(&format!(
        "SELECT * FROM {} WHERE tenant_id=?1 AND updated_at>?2",
        table_name
    ))?;
    let rows = stmt.query_map(params![tenant_id, since], decoder)?;
    rows.collect()
}
