import Foundation
import GRDB

// This file layers fixed-table migrations on top of the generated migrator.
// Add your fixed migrations inside `migratorWithFixedTables()` over time.
// Keep generated code and hand-written migrations separate.

extension SchemaMigrator {
    public static func migratorWithFixedTables() -> DatabaseMigrator {
        var migrator = migrator() // start with the generated migrations
        migrator.registerMigration("fixed") { db in
            try db.create(table: "overlays") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("object_id", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("changes", .jsonText).notNull()
                t.column("created_at", .datetime).notNull().defaults(to: Date())
            }
        }
            
        return migrator
    }
}

