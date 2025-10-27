EPIC-01: The Core Sync Platform (The "Moat")
1. Goals (The "Why")
This epic will create the foundational platform that is the competitive advantage. The goals are to:

Provide an "Instant Data Guarantee" (live sync) across all clients.

Ensure "True Offline-First" architecture where web and mobile clients operate on a local, replicated SQLite database.

Implement a Secure, Replicated DB Model: Clients will have their local DB populated with data filtered by a security profile-aware "channel" (pub/sub topic) on the WebSocket.

Maximize Backend Efficiency: Multiple clients with the same filter (e.g., "Company-A, Admin-Role") can subscribe to the same WebSocket channel, minimizing server load.

Minimize Cost-to-Serve: The entire system will be powered by a highly efficient Rust backend with robust error handling to minimize support costs and allow for running on minimal hardware (e.g., a single droplet).

Enable a Dynamic Platform: The object_metadata and layout_definition tables themselves will be part of this sync, allowing platform customizations to be reflected instantly on all clients.

2. Implementation Notes (The "How")
Backend: Rust

Transport: WebSockets (not REST)

Client DB: SQLite

Server DB: SQLite

Sync Logic (Online): json diffs sent immediately over the WebSocket for any write.

Sync Logic (Offline):Getcha-up: Client stores local changes as json diffs in a local overlays table. Upon reconnect, client sends queued diffs and reconciles with the server, likely using timestamps.

Client-Side Architecture:

server_data tables: Read-only, reflecting the latest known "golden" state from the server.

overlays table: A write-only log of local mutations (diffs) made by the user.

UI Layer: A dynamic projection that merges server_data with the overlays table to show the user's real-time state.

Merge Strategy:

Auto-Merge (99%): Non-conflicting merges (e.g., Admin edits job.notes, Tech edits job.line_items) are merged automatically and silently.

Manual-Merge (1%): True conflicts (e.g., Admin and Tech edit job.price at the same time) will trigger a simple "show an alert" UX for the user to resolve.

3. Definition of Done (The "Exit Criteria")
This epic is complete when the following end-to-end functionality is proven:

Clients Exist: A functional iOS client and a web client are built and can connect to the Rust backend.

Dynamic Objects: Clients dynamically render a list of available object types (e.g., "Jobs," "Inventory") based only on the data synced to the local object_metadata table.

Dynamic Layouts: Tapping a data row (e.g., a specific Job) renders a detail view with fields, labels, and UI elements defined only by the data in the synced layout_definition table.

Live Sync is Proven: Making an edit to a record in one client (e.g., changing a job's status on the web client) is reflected on the other client (iOS) virtually instantly, with no manual refresh or "pull" required.

### Sub Epics
1. Backend: WebSocket & Pub/Sub Server: All the Rust work to handle secure connections, manage state, define the pub/sub channels (based on security/filter profiles), and efficiently broadcast diffs to all subscribed clients.

2. Client: Core DB Schema: Defining the exact SQLite schema for the client, including the server_data tables, the overlays table, and, most importantly, the structure of the object_metadata and layout_definition tables.

3. Client: The "Sync Engine" (State Machine): This is the heart of it. All the logic for connecting, handling the offline queue, applying diffs, running the auto-merge for non-conflicting changes, and triggering the "alert" for true conflicts.

4. Client: The "Dynamic UI Engine": A non-trivial piece of work. This is the UI code that reads object_metadata to build a list and reads layout_definition to dynamically render a record's detail page.

5. The "End-to-End Test Harness": The specific clients (iOS/Web) and backend setup to prove the exit criteria, specifically making a change on one client and seeing it instantly appear on the other.