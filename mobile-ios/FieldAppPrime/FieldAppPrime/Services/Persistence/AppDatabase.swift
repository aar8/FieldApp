import Foundation
import GRDB

/// Defines specific errors that can occur during database setup.
enum DatabaseError: Error {
    case failedToAccessApplicationSupport(underlyingError: Error)
    case failedToCreateDatabaseQueue(underlyingError: Error)
    case migrationFailed(underlyingError: Error)
}

/// The protocol for the AppDatabase, allowing for mock/fake implementations for testing.
protocol AppDatabaseProtocol {
    var dbQueue: DatabasePool { get }
}

/// `AppDatabase` is responsible for setting up the database connection and managing schema migrations.
final class AppDatabase: AppDatabaseProtocol {
    
    let dbQueue: DatabasePool
    
    private init(dbQueue: DatabasePool) {
        self.dbQueue = dbQueue
    }
    
    /// Factory method to create and set up the database.
    ///
    /// - Returns: A `Result` containing a fully initialized `AppDatabase` on success, or a specific `DatabaseError` on failure.
    static func create() -> Result<AppDatabase, DatabaseError> {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dbURL = appSupportURL.appendingPathComponent("fieldapp.sqlite")
            print(dbURL)
            let dbQueue = try DatabasePool(path: dbURL.path)
            let appDatabase = AppDatabase(dbQueue: dbQueue)
            
            try appDatabase.migrator.migrate(dbQueue)
            
            return .success(appDatabase)
            
        } catch {
            // If any step fails, capture the error and return a failure result.
            return .failure(.migrationFailed(underlyingError: error))
        }
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            try db.create(table: JobRecord.databaseTableName) { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
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
            
            try db.create(index: "idx_jobs_status", on: JobRecord.databaseTableName, columns: ["status"])
            
            try db.create(table: ObjectMetadataRecord.databaseTableName) { t in
                t.primaryKey("id", .text)
                t.column("tenant_id", .text).notNull()
                t.column("object_name", .text).notNull()
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
