import Foundation
import GRDB
import ReactiveSwift

// MARK: - Database Service Protocol

protocol DatabaseService {
    /// A property representing the list of jobs. 
    /// New subscribers immediately receive the current list of jobs and then all future updates.
    var jobs: Property<[Job]> { get }
    
    /// Upserts an array of job records into the database.
    /// - Parameter jobs: The job records to save.
    /// - Returns: A `Result` indicating success or failure.
    func upsert(jobs: [JobRecord]) -> Result<Void, Error>
}

// MARK: - Default Implementation

class DefaultDatabaseService: DatabaseService {
    private let dbQueue: DatabaseQueue
    let jobs: Property<[Job]>
//    let cancellable: AnyDatabaseCancellable
    init(appDatabase: AppDatabaseProtocol) {
        let dbQueue = appDatabase.dbQueue
        self.dbQueue = dbQueue
        
        let observation = ValueObservation.tracking { db in
            try JobRecord.fetchAll(db)
        }
        
//        let cancellable = observation.start(
//            in: dbQueue,
//            onError: { error in
//                // TODO: Log the database error to our logging service.
////                observer.send(value: [])
//            },
//            onChange: { records in
//                let jobs = records.map { $0.toDomainModel() }
////                observer.send(value: jobs)
//            }
//        )
        
        let jobsProducer = SignalProducer<[Job], Never> { observer, lifetime in
//            lifetime.observeEnded { cancellable.cancel() }
        }
        
//        self.cancellable = cancellable
        self.jobs = Property(initial: [], then: jobsProducer)
    }
    
    func upsert(jobs: [JobRecord]) -> Result<Void, Error> {
        do {
            try dbQueue.write { db in
                for job in jobs {                
                    try job.save(db)
                }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Mock Service

class MockDatabaseService: DatabaseService {
    let jobs: Property<[Job]>
    
    init() {
        let sampleJobs = [
            Job(id: "1", tenantId: "t1", objectType: "job", status: "Scheduled", data: JobDomainData(title: "Install new HVAC unit", description: ""), version: 1, createdAt: Date(), updatedAt: Date()),
            Job(id: "2", tenantId: "t1", objectType: "job", status: "In Progress", data: JobDomainData(title: "Repair leaking pipe", description: ""), version: 1, createdAt: Date(), updatedAt: Date()),
            Job(id: "3", tenantId: "t1", objectType: "job", status: "Completed", data: JobDomainData(title: "Quarterly generator maintenance", description: ""), version: 1, createdAt: Date(), updatedAt: Date())
        ]
        
        self.jobs = Property(value: sampleJobs)
    }
    
    func upsert(jobs: [JobRecord]) -> Result<Void, Error> {
        // In the mock service, the upsert can just succeed without doing anything.
        return .success(())
    }
}
