# FieldApp Project Context

## Project Overview
Building a stealth CRM platform disguised as vertical niche apps (HVAC, rental management). The goal is to create a "hyper speed syncing CRM kernel" while earning revenue and refining the platform in low-competition markets before revealing it's actually a Salesforce competitor.

## The Strategy
- **Phase 1**: Build MVP in "kiddie pool" verticals (HVAC/rental) to get paying customers
- **Phase 2**: Refine the sync engine and platform capabilities
- **Phase 3**: Reveal the platform play once battle-tested
- **Unfair Advantage**: 10 years at Salesforce/Veeva - knows exactly what enterprises need AND what's broken

## Tech Stack
- **Server**: Rust backend, SQLite database
- **Clients**: iOS (Swift/GRDB/SwiftUI), Web (planned), Android (planned)
- **Sync Architecture**:
  - SQLite everywhere (same schema server + clients)
  - "Since" polling for initial sync
  - WebSocket JSON deltas for real-time once current
  - Shared delta channels for multi-client real-time collaboration
  - Version-based optimistic concurrency control

## Core Architecture Insights
- **Hybrid Schema**: Fixed tables (jobs, customers, users, etc.) with JSON `data` blobs for flexibility
- **Metadata-Driven**:
  - `object_metadata` table defines fields dynamically
  - `layout_definitions` table controls UI based on `(object_name, object_type, status)` tuples
  - This allows customization without schema changes
- **The Moat**: True offline-first + instant sync (Salesforce is slow even online)

## Code Generation System
Built a TypeScript-based codegen that produces:
- Server SQL schema (`init.generated.sql`)
- iOS Swift entity types (domain objects)
- iOS DB migrations (`SchemaMigrator.generated.swift`)
- Auto-generated `object_metadata` and `layout_definitions` records
- Type-safe TS scenario builder for instant seed data creation

**Why**: After manually building just the Job entity, the cognitive load of handling 5+ entities plus metadata became overwhelming. Codegen solves this - can now create valid test data instantly.

## What's Currently Working (v0.1)
- ✅ Rust backend: SQLite → unified JSON sync response (all entity types)
- ✅ iOS client: GRDB with codegen'd Swift entities + schema init
- ✅ iOS sync state machine: makes initial `/sync` request, upserts to local DB
- ✅ iOS reactive DB service: watches DB → feeds VM → renders job list in SwiftUI
- ✅ **One entity (Job) flowing end-to-end from server → iOS UI**
- ✅ Codegen system complete and working

## Epic 1 MVP Scenario Requirements
See `/Users/adrian/work/FieldApp/plan/specs/epic_1_mvp_scenario.md` for full scenario.

**Core flows needed**:
1. Sync down (✅ working for iOS)
2. Edit & save locally
3. Sync changes to server
4. Broadcast to other devices
5. Works on both iOS and Web

**Key entities in scenario**: Job, Customer, User, Quote, CalendarEvent, ObjectFeed, Invoice

## Current State (as of session start)
- Just finished 3-day codegen build sprint
- Ready to transition from codegen → iOS metadata-driven UI
- **Next immediate goal**: Build metadata-driven detail/edit view in iOS
  - Reads `layout_definitions` + `object_metadata` from local DB
  - Renders dynamic form based on metadata
  - Once this works, get edit views for ALL entities for free

## Project Management Notes
- Working solo, need help tracking tasks without cognitive overhead
- Don't want code generation help - just project tracking and context persistence
- Need granular task breakdown (15-min chunks), not epic-level views
- Git repo at: `/Users/adrian/work/FieldApp/`
- Codegen tool at: `/Users/adrian/work/FieldApp/tools/schema-codegen/`

## Key Files
- Schema definition: `/Users/adrian/work/FieldApp/plan/specs/schema.ts`
- Epic 1 scenario: `/Users/adrian/work/FieldApp/plan/specs/epic_1_mvp_scenario.md`
- 50k ft plan: `/Users/adrian/work/FieldApp/plan/specs/50_000_ft_plan.md`
- Generated SQL: `/Users/adrian/work/FieldApp/server/init.generated.sql`
- iOS models: `/Users/adrian/work/FieldApp/mobile-ios/FieldAppPrime/FieldAppPrime/Models/`
- iOS migrations: `/Users/adrian/work/FieldApp/mobile-ios/FieldAppPrime/FieldAppPrime/Services/Persistence/SchemaMigrator.generated.swift`