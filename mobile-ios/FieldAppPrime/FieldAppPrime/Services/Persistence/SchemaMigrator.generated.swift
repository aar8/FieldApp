// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import Foundation
import GRDB


struct SchemaMigrator {
    static func migrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { db in
            try db.create(table: "jobs") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "users") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "customers") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "calendar_events") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "pricebooks") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "products") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "locations") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "product_items") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "pricebook_entries") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "job_line_items") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "quotes") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "object_feeds") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "invoices") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "invoice_line_items") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("status", .text).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("data", .jsonText).notNull()
            }
            try db.create(table: "object_metadata") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text)
                t.column("object_name", .text).notNull()
                t.column("data", .jsonText).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
            }
            try db.create(table: "layout_definitions") { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text)
                t.column("object_name", .text).notNull()
                t.column("object_type", .text).notNull()
                t.column("status", .text).notNull()
                t.column("data", .jsonText).notNull()
                t.column("version", .integer).notNull()
                t.column("created_by", .text)
                t.column("modified_by", .text)
                t.column("created_at", .text).notNull()
                t.column("updated_at", .text).notNull()
            }
        }
        return migrator
    }
}