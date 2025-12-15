import Foundation
import GRDB
import ReactiveSwift
import Insieme

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

    func saveJobChanges(_ jobChanges: JobDataUpdates, for job: Job) -> Result<Void, Error>
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
            let observation = ValueObservation.tracking { db -> [Job] in
                let jobRecords = try! JobRecord.fetchAll(db)
                let overlayRecords = try! OverlayRecord.filter(Column("object_name") == "job").fetchAll(db)
                
                let overlaysByObjectId = Dictionary(grouping: overlayRecords, by: { $0.objectId })
                
                let jobs = jobRecords.map { jobRecord -> Job in
                    var job = jobRecord.model
                    
                    guard let jobOverlays = overlaysByObjectId[job.id] else { return job }

                    let sortedOverlays = jobOverlays.sorted { $0.createdAt < $1.createdAt }
                    
                    let finalUpdates: JobDataUpdates = .from(overlays: sortedOverlays)
                    
                    // sortedOverlays.reduce(into: JobDataUpdates()) { acc, overlay in
                    //     guard let updates = try? JSONDecoder().decode(JobDataUpdates.self, from: overlay.changes) else  { return }

                    //     acc.jobNumber = acc.jobNumber.merged(with: updates.jobNumber)
                    //     acc.customerId = acc.customerId.merged(with: updates.customerId)
                    //     acc.jobAddress = acc.jobAddress.merged(with: updates.jobAddress)
                    //     acc.jobDescription = acc.jobDescription.merged(with: updates.jobDescription)
                    //     acc.assignedTechId = acc.assignedTechId.merged(with: updates.assignedTechId)
                    //     acc.statusNote = acc.statusNote.merged(with: updates.statusNote)
                    //     acc.quoteId = acc.quoteId.merged(with: updates.quoteId)
                    //     acc.equipmentId = acc.equipmentId.merged(with: updates.equipmentId)
                    // }
                    job = job.applying(updates: finalUpdates)
                    // }
                    return job
                }
                return jobs
            }
                
            let cancellable = observation.start(
                in: dbQueue,
                onError: { error in
                    // TODO: Log the database error to our logging service.
                },
                onChange: { (jobs: [Job]) in
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

    func saveJobChanges(_ jobChanges: JobDataUpdates, for job: Job) -> Result<Void, Error> {
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
            
            try dbQueue.write { db in
                try overlayRecord.save(db)
            }
            
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
