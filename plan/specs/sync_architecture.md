# Sync Architecture Plan

This document outlines the architecture for the real-time, delta-based synchronization feature.

## Core Pattern: Change Log

The foundation of the sync engine is a "Change Log" pattern, similar to event sourcing. Instead of updating records directly, we log each change as a discrete event. This provides resilience, data integrity, and a clear history of mutations.

### Client-Side (`overlays` table)

-   The client uses its local SQLite `overlays` table as a **temporary queue** for unsynced changes.
-   When a user modifies data, a new row is `INSERT`ed into this table. Each row contains a "delta" (a JSON object representing the specific change).
-   This is an append-only operation on the client, which is simple and robust.
-   After a change is successfully sent to the server and confirmed, the corresponding row is **deleted** from the local `overlays` table.
-   This ensures the table only ever contains pending changes and does not grow indefinitely.

### Server-Side (Rust/SQLite `changes` table)

-   The Rust backend also uses a `changes` log table in its SQLite database.
-   This table's primary purpose is to ensure **transactional integrity for sync operations** and to efficiently calculate diffs for clients.
-   Unlike a permanent event store, the server can **periodically prune or compact** this log to keep the database file size manageable, once it has verified that changes have been distributed to all clients.

## V1 Merge Strategy: Last Write Wins (LWW)

-   For the initial implementation, the server will adopt a simple "Last Write Wins" strategy.
-   When the server receives a delta from a client, it will apply it directly to the master record without performing complex conflict checks.
-   **Trade-off:** This is simple to implement and gets the end-to-end system working quickly, but it carries the risk of silently overwriting data if two users edit the same record while offline. This is an acceptable trade-off for V1.

## Data Integrity: Chained Hash Verification

To allow clients to verify they are perfectly in sync with the server (a "git-like" approach), we will implement a chained hash system.

-   The server will maintain a `state_hash` that represents the definitive state of the data.
-   This hash is computed as a chain: `H_new = hash(hash(new_change) + H_previous)`.
-   This creates a tamper-proof "blockchain" for the data history and is highly performant to calculate.
-   **Sync Flow:**
    1.  Client sends its changes along with the last known `state_hash`.
    2.  The server processes the changes and calculates the new, authoritative `state_hash`.
    3.  If the client was out of date, the server sends back the missed deltas *and* the final `state_hash`.
    4.  The client applies the deltas and confirms that its own calculated hash matches the one from the server.
-   This provides cryptographic proof of data integrity and a reliable way to detect sync errors.

## Future Evolution

This architecture is designed to be extensible. After V1 is established, we can evolve the merge strategy from LWW to a more sophisticated conflict resolution system (e.g., rejecting conflicting changes, providing UI for manual merges) by adding versioning information to the deltas, without changing the core infrastructure.
