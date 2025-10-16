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
    var dbQueue: DatabaseQueue { get }
}

/// `AppDatabase` is responsible for setting up the database connection and managing schema migrations.
final class AppDatabase: AppDatabaseProtocol {
    
    let dbQueue: DatabaseQueue
    
    private init(dbQueue: DatabaseQueue) {
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
            
            let dbQueue = try DatabaseQueue(path: dbURL.path)
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
                t.column("tenantId", .text).notNull()
                t.column("objectType", .text).notNull()
                t.column("data", .jsonText).notNull()
                t.column("version", .integer).notNull()
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                
                t.column("status", .text)
                    .generatedAs(sql: "json_extract(data, '$.status')")
            }
            
            try db.create(index: "idx_jobs_status", on: JobRecord.databaseTableName, columns: ["status"])
        }
        
        return migrator
    }
}
