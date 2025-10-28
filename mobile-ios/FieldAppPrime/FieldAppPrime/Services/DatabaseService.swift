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
}

// MARK: - Default Implementation

class DefaultDatabaseService: DatabaseService {
    private let dbQueue: DatabasePool
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
                    let jobs = records.map(\.domainModel)
                    observer.send(value: jobs)
                }
            )
            lifetime.observeEnded { cancellable.cancel() }
        }
        
        self.jobs = Property(initial: [], then: jobsProducer)
    }
    
    func upsert(syncResponse: SyncResponse) -> Result<Void, Error> {
        do {
            try dbQueue.write { db in
                let jobs = syncResponse.data.jobs.map { $0.asJobRecord }
                for job in jobs {
                    try job.save(db)
                }
                
                let metadata = syncResponse.data.objectMetadata.map { $0.asObjectMetadataRecord }
                for record in metadata {
                    try record.save(db)
                }
                
                let layouts = syncResponse.data.layoutDefinitions.map { $0.asLayoutDefinitionRecord }
                for layout in layouts {
                    try layout.save(db)
                }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
