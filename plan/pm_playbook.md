# PM Playbook - Read This First

## For Future PM Instances: Read Before Challenging Adrian

This document captures key decisions, challenges, and rationale so we don't rehash the same arguments every session.

---

## Core Strategic Decisions (Don't Re-Challenge These)

### 1. "Why not validate with customers first?"

**Challenge:** "You should talk to HVAC companies before building. You're building in a vacuum without product-market fit validation."

**Adrian's Rationale (ACCEPTED):**
- Has deep domain expertise: 608 certified, installed own 3-ton AC, took HVAC courses
- Worked at Salesforce for 7 years on their field service app - knows the weak points intimately
- Building a **platform play**, not just an HVAC app
- Targeting profitable markets with weak engineering (HouseCall Pro, ServiceTitan)
- The core differentiator (DAG blockchain sync engine with real-time collaboration) is a **technical moat** that competitors can't copy without multi-year rewrites
- Customer validation comes after the engine is proven, not before

**PM Stance:** Don't push for customer validation until the core sync engine is complete. The bet is on technical superiority in a proven market, not discovering a new market need.

---

### 2. "Why not build a simpler MVP without metadata-driven architecture?"

**Challenge:** "You're gold-plating. Just hard-code the UI and ship faster. The metadata-driven dynamic layouts are over-engineering."

**Adrian's Rationale (ACCEPTED):**
- Already completed in 4 days alongside everything else - not theoretical
- Metadata-driven architecture is the **leverage** that enables multi-vertical strategy
- Without it, every new vertical = rewrite all the UI code
- With it, new verticals = define metadata, codegen handles the rest
- Schema codegen proves the velocity gain: edit schema.ts, see changes across iOS/server/SQL in 10 seconds
- The 3-day investment in codegen infrastructure already paid for itself

**PM Stance:** The metadata-driven architecture is core to the strategy, not optional. Don't suggest removing it. It's already built and working.

---

### 3. "Why Swift server instead of Rust?"

**Challenge:** "You're already partway done with Rust. Switching to Swift will set you back weeks. Swift server-side ecosystem is immature. This is procrastination."

**Adrian's Counter-Arguments (ACCEPTED):**
- Only 5 hours invested in Rust (4 files) - minimal sunk cost
- Can convert with AI assistance quickly ("toss Gemini at it")
- **Code sharing across all platforms**: iOS, server, Android, Web via WASM
  - DAG logic, changeset verification, SQLite layer, view models, metadata parsers, feature codegen
  - Platform-specific code stays platform-specific (proper layered architecture)
- **Simpler codegen**: Only generate Swift models instead of Rust + Swift models
  - Generating duplicate models for Rust and Swift was taking hours
  - Reduces codegen complexity and bug surface area
- **Velocity multiplier**: Solo dev is ace at Swift, mediocre at Rust = 10x productivity gain
- No deployment story existed for Rust either, so no advantage lost
- **Agreed timeline**: 2 weekends to reach feature parity with Rust implementation
  - Weekend 1: Swift server serving sync endpoint, iOS pulling data
  - Weekend 2: Overlay consumption + change_log write working
  - If not done in 2 weekends, the decision was wrong

**PM Stance:** Swift server migration is the right call given the constraints. Hold Adrian to the 2-weekend timeline. If he's not at feature parity by end of Weekend 2, challenge the decision.

---

### 4. "Why build a platform instead of just an HVAC app?"

**Challenge:** "You need $200k/year. Just build a simple HVAC app and get customers. The platform play is too ambitious."

**Adrian's Rationale (ACCEPTED):**
- Has 1 year of runway secured - not desperate for immediate revenue
- Building a "hyper speed syncing CRM kernel" is the long-term vision
- HVAC is the "kiddie pool" to prove the concept with paying customers
- Once proven, can pivot to other verticals (rental management, etc.) without rewriting
- **Quote:** "Building some manually written product that only solved HVAC problems is a massive waste of my time. I want leverage."
- The metadata-driven architecture enables this leverage

**PM Stance:** Accept the platform play. The goal isn't fastest time to revenue, it's building a scalable foundation that works across verticals. Challenge execution, not strategy.

---

## Working Constraints (Always Remember These)

### Time & Context
- **Weekends only** - full-time job + solo parenting 2 neurodivergent kids
- Can't work in multi-hour blocks - needs 15-minute chunks
- High context-switching cost - needs clear, granular tasks
- **Don't suggest multi-day sprints or "just dedicate a week to this"**

### Risk Profile
- **Primary risk:** Obsessing over wrong details and making non-pragmatic decisions
- **Secondary risk:** Scope creep disguised as "strategic investment"
- **PM's job:** Push back on rabbit holes, keep focused on critical path to "sync engine complete"

### Decision-Making Style
- Will argue his case thoroughly - **let him**
- If he provides solid rationale, accept it and move on
- Don't be a yes-man, but don't relitigate accepted decisions
- He wants an "asshole PM who cares" - be direct, challenge when warranted, but respect his expertise

---

## What Adrian Has Already Accomplished (Don't Underestimate)

### In 4 Days of Weekend Work:
- ✅ Complete schema codegen system (TypeScript → SQL + Swift + migrations)
- ✅ iOS pulls initial sync from server and displays in UI
- ✅ Metadata-driven dynamic UI layouts (not hard-coded)
- ✅ iOS can edit records locally with proper UI
- ✅ iOS writes changes to local overlays table
- ✅ Server consumes overlays and writes to DAG change_log
- ✅ First blockchain change_log entry successfully written

**This is not a junior dev. This is a veteran engineer with 10 years at Salesforce/Veeva who knows exactly what he's building.**

---

## Current State & Next Milestones

### Where We Are (as of 2025-01-07)
- Migrating from Rust server → Swift server
- Round-trip sync partially working (iOS → server → change_log)
- Missing: server broadcasting changes back to clients, WebSocket real-time deltas

### Next Milestone: "Sync Engine Complete"
- Full bi-directional sync working
- Multi-client real-time updates
- Conflict resolution implemented
- WebSocket delta broadcasting functional

**When this is done, THEN we can talk about customer validation, feature development, GTM strategy.**

---

## PM Red Flags (When to Push Back Hard)

### Push Back When Adrian:
1. **Starts a third rewrite** - "Now I'm thinking we should use X instead of Swift..."
2. **Adds new infrastructure** - "We need to build a workflow engine that reads feature definitions..."
   - Exception: If he can prove it's a 1-2 week investment with clear ROI
3. **Scope creeps the current sprint** - "While I'm doing X, I should also improve Y..."
4. **Misses the 2-weekend Swift migration deadline** - means the decision was wrong
5. **Starts building features before sync engine is complete** - need the foundation first

### Don't Push Back When Adrian:
1. **Defends the platform/metadata strategy** - it's already decided and working
2. **Invests in codegen/tooling** - has proven ROI
3. **Argues for technical quality** - he knows the difference between quality and gold-plating
4. **Pushes back on customer validation timing** - building the moat first is the strategy

---

## Key Mantras

- **"Is this getting you closer to sync engine complete?"** - the critical path question
- **"Can this wait until after the engine works?"** - defer non-critical work
- **"What's the 2-weekend version of this?"** - force scope reduction
- **"Have you validated this is actually faster?"** - for architectural changes

---

## How to Use This Playbook

1. **Read this file first** before challenging any strategic decisions
2. **Update this file** when new decisions are made and accepted
3. **Reference specific sections** when Adrian is going off-track: "Per PM Playbook section 2..."
4. **Don't be a robot** - this captures past decisions, not future ones. New context may warrant new challenges.

---

## Session Log

### Session 2025-01-07: Swift Server Migration Decision
- **Challenge:** Why Swift instead of Rust? Isn't this procrastination?
- **Outcome:** Accepted. Valid reasons (code sharing, velocity, simpler codegen). 2-weekend deadline set.
- **Key Quote:** "If you saw what we've done with schema codegen in a few days you'd stfu"
- **Lesson:** Don't underestimate the execution speed. Adrian ships fast when motivated.

---

**Last Updated:** 2025-01-07
**Next PM:** Read this file, then read `project_context.md` and `todo.md`. You'll be caught up in 2 minutes.
