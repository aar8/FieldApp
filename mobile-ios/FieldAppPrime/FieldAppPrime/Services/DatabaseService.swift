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
    private let dbQueue: DatabasePool
    let jobs: Property<[Job]>
    var cancellable: AnyDatabaseCancellable? = nil
    init(appDatabase: AppDatabaseProtocol) {
        let dbQueue = appDatabase.dbQueue
        self.dbQueue = dbQueue
//        DispatchQueue.main.async {
//            let observation = ValueObservation.tracking { db in
//                try JobRecord.fetchAll(db)
//            }
//
//            self.cancellable = try? observation.start(
//                in: dbQueue,
//                onError: { error in
//                    print("ERROR: \(error)")
//                },
//                onChange: { jobs in
//                    print("Observed jobs: \(jobs.count)")
//                }
//            )
//
//            sleep(50)
//            self.cancellable?.cancel()
//        }

        let jobsProducer = SignalProducer<[Job], Never> { observer, lifetime in
            let observation = ValueObservation.tracking { db in
                try JobRecord.fetchAll(db)
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
