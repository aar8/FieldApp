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

## Current State (as of 2025-01-07)
- ✅ Metadata-driven detail/edit views working in iOS
- ✅ iOS writes edits to local overlays table
- ✅ Server can consume overlays and write to DAG change_log
- ✅ First blockchain change_log entry successfully written
- 📍 **Decision Made**: Migrating from Rust server → Swift server
  - Only 5 hours invested in Rust (4 files)
  - Swift shared across iOS, server, future Android/Web via WASM
  - Share critical code: DAG logic, changeset verification, SQLite layer, view models, metadata parsers
  - Simpler codegen: only generate Swift models (not Rust + Swift)
  - Solo dev is ace at Swift, mediocre at Rust = 10x velocity gain
  - **Timeline**: 2 weekends to reach feature parity with Rust implementation

## Current Sprint: Swift Server Migration
**Weekend 1 Goal**: Swift server serving sync endpoint, iOS pulling data
**Weekend 2 Goal**: Overlay consumption + change_log write working

See `/Users/adrian/work/FieldApp/plan/todo.md` for detailed task breakdown.

## Real Constraints & Strategy
- **Time**: Weekends only (full-time job + solo parenting 2 neurodivergent kids)
- **Revenue Goal**: $200k/year to help friend in need
- **Runway**: Secured 1 year of funding
- **Risk Profile**: Obsessing over wrong details vs. pragmatic progress
- **Strategic Bet**: Building multi-vertical platform with metadata-driven architecture, not single HVAC app
  - Leverage = can pivot across verticals (HVAC, rental management, etc.) without rewriting
  - Core moat = DAG blockchain sync engine with guaranteed correctness + real-time collaboration
  - Targeting profitable markets with weak engineering (HCP, etc.)
- **Customer Validation**: None yet (intentional - building core engine first, then vertical features)
- **Go-to-Market Plan**: Clone competitor features, describe in metadata, codegen on top of platform, beat on price (50% off) and superior sync/offline

## Project Management Notes
- Working solo, need help tracking tasks without cognitive overhead
- Need PM to push back on non-pragmatic decisions and scope creep
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