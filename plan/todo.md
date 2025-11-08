#### TODO

## Epic 1: Two Users Interacting with Real-Time Sync

### Completed
- [x] Decide on mvp scenario schema
- [x] Create MVP scenario schema
- [x] Update Schema
- [x] Add mvp scenario data creation script
- [x] Sync down new data to iOS
- [x] Show data on row
- [x] Clean up iOS code
- [x] Centralize schema definition
- [x] Generate SQL from schema def
    - [x] Verify using sqlite
- [x] Find a way to include or exclude types from generation
- [x] Swift records from schema def
- [x] Create Job detail view component in SwiftUI (basic navigation from list)
- [x] Wire up tap gesture on job list to navigate to detail view

### Current Sprint: Metadata-Driven Detail/Edit View
- [x] Query layout_definitions table for job + status to get field list
- [x] Query object_metadata table to get field type definitions
- [x] Render first field from metadata as a static label (proof of concept)
- [x] Generate value(for:) method for dynamic field access
- [x] Render ALL layout fields in form with actual values
- [x] add object metadata mvp data
- [x] sync down object metadata
- [x] define layout format

### Completed: Local Edit & Save Flow
- [x] Make one field editable (TextField for job_description)
- [x] Add Save button to detail view
- [x] Wire Save button to stub function (prints for now)
- [x] Design overlay table schema
- [x] Add overlay table to schema.ts and regenerate
- [x] Implement actual save to overlay table
- [x] Verify overlay changes persist after app restart
- [x] iOS writes changes to local overlays table
- [x] Server can consume overlays and write to DAG change_log
- [x] First blockchain change_log entry successfully written via seeding script

### CURRENT SPRINT: Swift Server Migration (Weekend 1 & 2)
**Goal:** Convert Rust server to Swift to share codebase across all platforms

**Weekend 1 Target:** Swift server serving sync endpoint, iOS pulling data
- [ ] Convert Rust server to Swift - get basic HTTP server running
- [ ] Update Swift codegen to generate shared models (remove Rust model generation)
- [ ] Port SQLite query logic from Rust to Swift
- [ ] Implement /sync endpoint in Swift server
- [ ] Test iOS app can pull data from Swift server

**Weekend 2 Target:** Overlay consumption + change_log write working
- [ ] Port overlay consumption logic to Swift server
- [ ] Port DAG change_log write logic to Swift server
- [ ] Test full round-trip: iOS edit → Swift server → change_log entry
- [ ] Verify change_log blockchain integrity in Swift implementation

### Future: Sync Upload Engine
- [ ] Build change tracking system (detect modified records since last sync)
- [ ] Implement POST endpoint on server for receiving changes
- [ ] Build iOS sync upload flow (serialize changed records, POST to server)
- [ ] Handle server response (success/conflicts)
- [ ] Mark records as synced after successful upload

### Future: Server-Side Sync Merge
- [ ] Implement conflict detection (version mismatch)
- [ ] Build merge logic for concurrent edits
- [ ] Return conflicts to client for resolution
- [ ] Persist merged changes to server DB

### Future: WebSocket Delta Broadcast
- [ ] Set up WebSocket infrastructure on server
- [ ] Implement delta channel subscriptions (by tenant_id)
- [ ] Broadcast changes to all connected clients in tenant
- [ ] Handle client reconnection and catch-up

### Future: iOS Delta Receive & Apply
- [ ] Connect to WebSocket on sync engine startup
- [ ] Subscribe to tenant's delta channel
- [ ] Parse incoming delta messages
- [ ] Apply deltas to local DB (merge with local changes)
- [ ] Update UI reactively

### Future: Web Client
- [ ] Plan web client skeleton and showing jobs
- [ ] Set up web client project structure
- [ ] Implement SQLite WASM or IndexedDB adapter
- [ ] Build sync engine (matching iOS architecture)
- [ ] Create metadata-driven form renderer
- [ ] Connect to same WebSocket delta channels

### Future: Overlay Table
- [ ] overlay table

## Backlog Ideas
- [ ] Fix seed script tenant_id generation: generates new UUID every run, requires manual copy to iOS app
  - Options: hardcoded dev tenant_id, config file, or CLI flag
- [ ] **BUG: Codegen changeset application for all entity types**
  - Current state: Server can only apply changesets to jobs table (hardcoded)
  - Need: Codegen to generate changeset application logic for all entities
  - When: After two-device sync test proves the pattern works
  - Scope: Generate apply_changeset() for customers, users, invoices, etc.
- [ ] Implement changeset-based sync for real-time updates
  - Server logs all changes to changes table with changeset IDs
  - Clients can request "changes since changeset X" instead of full sync
  - Foundation for WebSocket delta broadcasting
  - More efficient than polling full sync
- [ ] Changes table scaling: Implement retention window or archival strategy
  - Problem: Unbounded growth as edit history accumulates
  - Solution options: 30-day retention, partition by time, changeset compaction, or move server to Postgres
  - When: Address when changes table hits 1M+ rows
- [ ] **CRITICAL: Improve server error handling and responses**
  - Current state: Errors are vague, non-deterministic, hard to debug
  - Violates the "deterministic correctness" principle we built the changeset system for
  - Need Result types, specific error codes, clear failure messages
  - Should be able to tell exactly what went wrong from error response
  - This is foundational for reliability - fix before shipping
- [ ] Budgey: Personal finance app using the same kernel (has Plaid integration already working)
  - Note: On hold until FieldApp generates revenue
  - Would validate kernel works across domains
  - Liability concerns for consumer finance data
