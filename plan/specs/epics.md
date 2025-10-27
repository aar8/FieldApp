Phase 1: High-Level Epics
1. EPIC-01: The Core Sync Platform (The "Moat")

What: This is the foundational, non-negotiable technology. It includes building the Rust backend, the WebSocket server, the client-side SQLite database structure (with server_data and overlays tables), and the "Proper Sync State Machine" logic (the diff, patch, and timestamp/merge engine) that handles all data synchronization and conflict resolution.

Why: This is the technical moat. Without this, there is no product, no "Instant Data Guarantee," and no competitive advantage.

2. EPIC-02: Core Business Infrastructure (The "Business")

What: This is the "boring" but essential plumbing to have a sellable product. It covers user authentication (sign-up, login, password reset), team/company management (inviting a tech to an organization), and the subscription/billing integration (e.g., Stripe) to manage the 14-day free trial and convert users to paid plans.

Why: This is the "automated machine" part of your GTM. It's required to filter users and capture revenue without manual intervention.

3. EPIC-03: The "Killer Demo" Verticals (The "Product")

What: This is the minimum set of user-facing features needed to execute the "Killer Demo" workflow. It includes the basic UI and logic for:

Job Management: Create, assign, and update job status (e.g., "Waiting for Inventory").

Inventory Management: A global parts list, a per-tech ("Truck") inventory, and the ability to mark a part as "used."

Dispatch & Awareness: A live map to see tech locations and a simple list/Gantt view to see the day's schedule.

Why: This is the tangible product you will show in the demo video. It's the "proof" that the core sync platform provides real-world value.

4. EPIC-04: The GTM & Onboarding Machine (The "Salesperson")

What: This is every non-product asset required to get your first customer. It includes the marketing landing page, the production of the "Killer Demo Video" itself, the simple in-app "welcome" flow for the 14-day trial, and the setup of the targeted paid ad campaigns.

Why: This is your salesperson. This epic is what finds your prospects and convinces them to sign up for the trial.