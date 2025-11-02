import Foundation
import GRDB
import ReactiveSwift

// MARK: - Database Service Protocol

protocol DatabaseService {
    /// A property representing the list of jobs. 
    /// New subscribers immediately receive the current list of jobs and then all future updates.
    var jobs: Property<[Job]> { get }
    
    /// Upserts all records from a sync response into the database in a single transaction.
    /// - Parameter syncResponse: The response from the server containing records to upsert.
    /// - Returns: A `Result` indicating success or failure.
    func upsert(syncResponse: SyncResponse) -> Result<Void, Error>
    
    func fetchLayoutDefinitions() -> Result<[LayoutDefinitionRecord], Error>
    func fetchObjectMetadata() -> Result<[ObjectMetadataRecord], Error>

}

// MARK: - Default Implementation

class DefaultDatabaseService: DatabaseService {
    let dbQueue: DatabasePool
    
    let jobs: Property<[Job]>
    var cancellable: AnyDatabaseCancellable? = nil
    init(appDatabase: AppDatabaseProtocol) {
        let dbQueue = appDatabase.dbQueue
        self.dbQueue = dbQueue

        let jobsProducer = SignalProducer<[Job], Never> { observer, lifetime in
            let observation = ValueObservation.tracking { db in
                try! JobRecord.fetchAll(db)
            }
                
            let cancellable = observation.start(
                in: dbQueue,
                onError: { error in
                    // TODO: Log the database error to our logging service.
                },
                onChange: { records in
                    let jobs = records.map(\.model)
                    observer.send(value: jobs)
                }
            )
            lifetime.observeEnded { cancellable.cancel() }
        }
        
        self.jobs = Property(initial: [], then: jobsProducer)
    }
    
    func fetchLayoutDefinitions() -> Result<[LayoutDefinitionRecord], Error> {
        do {
            let layouts = try dbQueue.read { db in
                try LayoutDefinitionRecord.fetchAll(db)
            }
            return .success(layouts)
        } catch {
            return .failure(error)
        }
    }

    func fetchObjectMetadata() -> Result<[ObjectMetadataRecord], Error> {
        do {
            let layouts = try dbQueue.read { db in
                try ObjectMetadataRecord.fetchAll(db)
            }
            return .success(layouts)
        } catch {
            return .failure(error)
        }
    }
}
