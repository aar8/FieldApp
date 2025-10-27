You are right. My apologies. I was recapping the debate, not documenting the outcome.

Here are the **decided-upon architectural details** for the Core Sync Platform (EPIC-01), based on your plan.

---

### **1. Data Model: "Table Per Type" (Relational)**

This is the core database architecture.
* The system will **NOT** use a single, generic `entities` table.
* It **WILL** use discrete, relational tables for each object type (e.g., `jobs`, `customers`, `invoices`, `inventory_items`).
* **Benefits:** This provides full relational integrity (foreign keys), native data types (`REAL`, `TEXT`), and simple, high-performance, per-table indexing.

---

### **2. Transport: Single BFFE WebSocket**

This defines the client-server communication.
* A **single, persistent WebSocket connection** will be established per client.
* This connection will function as a **BFFE (Backend For Frontend)**.
* This single "pipe" will multiplex *all* communication: authentication, schema commands, and data diffs.
* All data messages will be tagged with their target table (e.g., `{"table": "jobs", "payload": ...}`).

---

### **3. Schema Management: "Dynamic Schema"**

This is the key to *how* the "Table Per Type" model remains flexible.
* The `object_metadata` table drives the creation of *new* tables.
* When an admin adds a new object type (e.g., `"service_contract"`), the Rust backend will **dynamically generate and execute a `CREATE TABLE service_contracts (...)` migration** on the server.
* This is *not* a real-time, no-code *schema editor* for the user; it is a developer-defined mechanism for dynamically *extending* the platform with new, pre-defined object types.

---

### **4. Sync Logic: "Schema Version" Flow**

This is the critical mechanism that makes "Dynamic Schema" (Pillar 3) safe and robust. It prevents all race conditions.
1.  **Server Migration:** An admin change triggers a `CREATE TABLE ...` migration on the server.
2.  **Version Bump:** The backend **increments a global `schema_version`** for that tenant (e.g., `v2` -> `v3`).
3.  **Data Tagging:** All subsequent data diff messages (for any table) are **tagged with `schema_version: "v3"`**.
4.  **Client-Side Halt:** A `v2` client receives a `v3` message. It **stops processing all data diffs**.
5.  **Client Upgrade:** The client enters an "upgrading" state. It requests the new schema commands from the BFFE and **executes the `CREATE TABLE ...` migration on its local SQLite database**.
6.  **Sync Resumption:** The client updates its local version to `v3`, does a "sync since" request to get data it missed, and then resumes processing the live diff stream.

---n

### **5. Client-Side Architecture: The "Runtime Overlay"**

This defines the offline-first and non-destructive write capabilities.

1.  **Data Storage:** The client's local SQLite DB contains:
    * **Read-Only Tables (e.g., `jobs`, `customers`):** These tables mirror the "golden" server state.
    * **One `overlays` Table:** This table stores all local changes (creates, edits, deletes) as a log of `json diffs`, with each row tagged with the ID of the record it belongs to (e.g., `job-123`).

2.  **The "Overlay" Process (Runtime):** When the UI needs to display a record, it is **not** a direct `SELECT` from the `jobs` table. Instead, the application's repository layer performs a multi-step process in memory:
    * **Step 1 (Fetch Base):** It queries the read-only `jobs` table for the base JSON data (the last known server state).
    * **Step 2 (Fetch Diffs):** It queries the `overlays` table for all pending `json diffs` associated with that record's ID.
    * **Step 3 (Patch):** The client's logic takes the base JSON and applies the sequence of `json diffs` over it *in memory* to compute the final, current state.
    * **Step 4 (Render):** This resulting "patched" JSON object is what the UI renders.

This "runtime overlay" ensures that the UI always shows the user's latest work, even if it hasn't been synced. It also cleanly separates the known server state from local-only mutations, which is what enables the conflict resolution logic.
---

### **6. Metadata Schema: Compound Layout Binding
This defines the schema for the dynamic UI, using your corrected naming convention.

The layout_definition table will bind a UI layout to a compound key.

Binding Key:

object_name (e.g., "job", "customer")

object_type (e.g., "job_residential", "job_commercial", or a default)

status (e.g., "in_progress", "pending", or a * wildcard)

Result: This allows the app to dynamically render a completely different UI for a "Residential Job in Progress" vs. a "Commercial Job Pending." The client app will query this table using the object_name, object_type, and status of the record the user is viewing to get the correct layout_json to render.