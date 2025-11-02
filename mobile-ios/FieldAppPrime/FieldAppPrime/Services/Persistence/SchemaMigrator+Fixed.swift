import Foundation
import GRDB

// This file layers fixed-table migrations on top of the generated migrator.
// Add your fixed migrations inside `migratorWithFixedTables()` over time.
// Keep generated code and hand-written migrations separate.

extension SchemaMigrator {
    static func migratorWithFixedTables() -> DatabaseMigrator {
        var migrator = migrator() // start with the generated migrations

        // Register your fixed-table migrations here.
        // Example (replace with your real schema, and add versioning later):
        // migrator.registerMigration("fixed") { db in
        //     try db.create(table: "my_fixed_table") { t in
        //         t.primaryKey("id", .text)
        //         t.column("name", .text).notNull()
        //     }
        // }

        return migrator
    }
}

