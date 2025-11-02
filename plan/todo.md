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

### Next: Local Edit & Save Flow
- [x] Make one field editable (TextField for job_description)
- [x] Add Save button to detail view
- [x] Wire Save button to stub function (prints for now)
- [ ] Design overlay table schema
- [ ] Add overlay table to schema.ts and regenerate
- [ ] Implement actual save to overlay table
- [ ] Verify overlay changes persist after app restart

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
- [ ] Budgey: Personal finance app using the same kernel (has Plaid integration already working)
  - Note: On hold until FieldApp generates revenue
  - Would validate kernel works across domains
  - Liability concerns for consumer finance data
