import Foundation
import GRDB
import Insieme

public protocol SyncClientDatabase {
    // func upsert(syncResponse: SyncResponse) -> Result<Void, Error>
    
    func fetchLayoutDefinitions() -> Result<[LayoutDefinitionRecord], Error>
    func fetchObjectMetadata() -> Result<[ObjectMetadataRecord], Error>

    func saveJobChanges(_ jobChanges: JobDataUpdates, for job: Job) -> Result<Void, Error>
}

public class SyncClientDatabaseService: SyncClientDatabase {
    public typealias DatabaseAccess = DatabaseWriter & DatabaseReader
    let db: DatabaseAccess
    
    public init(appDatabase: DatabaseAccess) {
        self.db = appDatabase
    }
    
    public func fetchLayoutDefinitions() -> Result<[LayoutDefinitionRecord], Error> {
        do {
            let layouts = try db.read { db in
                try LayoutDefinitionRecord.fetchAll(db)
            }
            return .success(layouts)
        } catch {
            return .failure(error)
        }
    }

    public func fetchObjectMetadata() -> Result<[ObjectMetadataRecord], Error> {
        do {
            let layouts = try db.read { db in
                try ObjectMetadataRecord.fetchAll(db)
            }
            return .success(layouts)
        } catch {
            return .failure(error)
        }
    }

    public func saveJobChanges(_ jobChanges: JobDataUpdates, for job: Job) -> Result<Void, Error> {
        do {
            let jsonData = try JSONEncoder().encode(jobChanges)
            
            let overlayRecord = OverlayRecord(
                id: UUID().uuidString,
                tenantId: "default",
                objectId: job.id,
                objectName: job.objectName,
                changes: jsonData,
                createdAt: Date()
            )
            
            try db.write { db in
                try overlayRecord.save(db)
            }
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
