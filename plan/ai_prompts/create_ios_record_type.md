### ⚠️ Important: Source of Truth

Before starting, it is critical to understand the project's data schema hierarchy. This prevents confusion and incorrect modifications.

1.  **Primary Source of Truth: `plan/specs/schema.md`**
    *   This file contains the canonical definition for all data structures. All new development and refactoring must adhere to this specification.

2.  **Secondary Source of Truth: `server/init.sql`**
    *   This file contains the physical implementation of the schema for the server's database. It **must** accurately reflect `schema.md`. If there is a discrepancy, `schema.md` is considered correct and `init.sql` should be updated.

3.  **Implementation Code (iOS/Server): Must Follow Schema**
    *   All other code, including Swift models, server routes, and database access logic, **must** conform to the schema defined by the two files above.

**Example of what NOT to do:** An agent previously found that the `object_metadata` table in `init.sql` was missing `status` and `object_type` columns that were present in a Swift model. The agent incorrectly assumed `init.sql` was out of date and tried to add the columns during a migration. **This is wrong.** The correct action is to fix the Swift model to match the schema defined in `schema.md` and `init.sql`.

---

### Checklist for Adding iOS Support for an Existing Record Type

This checklist outlines the necessary steps to add full support for an existing server-defined entity to the iOS application.

**Prerequisite:** The record type (e.g., "Widget") must already be defined in `plan/specs/schema.md` and included in the server's `/sync` API response.

Let's assume we are adding iOS support for an existing record type called **"Widget"**.

1.  **Update API Model (`Models/SyncResponse.swift`)**
    *   Create a `WidgetData: Codable` struct that matches the `data` blob for the record in `schema.md`. Use `camelCase` properties and `CodingKeys` to map from the JSON's `snake_case`.
    *   Add the new `widgets: [APIRecord<WidgetData>]` property to the `DataPayload` struct.
    *   Add the `widgets` key to the `DataPayload.CodingKeys` enum.

2.  **Create Database Record Model (`Models/Records/WidgetRecord.swift`)**
    *   Create a new file `WidgetRecord.swift`.
    *   Define a concrete `struct WidgetRecord: Codable, FetchableRecord, PersistableRecord`. Its properties should mirror the `APIRecord` from the sync response.
    *   Explicitly define `static let databaseTableName = "widgets"`.
    *   Add an extension with a `domainModel` computed property to map the database record to the clean domain model.

3.  **Update Database Migration (`Services/Persistence/AppDatabase.swift`)**
    *   In the `migrator`, add a new `try db.create(table: WidgetRecord.databaseTableName)` block.
    *   Define all columns to match the server's `init.sql` schema for the `widgets` table. Ensure data types are correct (e.g., `.text` for date strings).

4.  **Create Domain Model (`Models/Widget.swift`)**
    *   Create a new file `Widget.swift`.
    *   Define a clean, flattened `struct Widget: Identifiable, Hashable` for use in SwiftUI views and business logic. This struct should contain the essential properties from the base record and its specific `data` blob.
