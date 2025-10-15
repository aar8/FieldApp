import Foundation
import GRDB
import ReactiveSwift


struct MyDomainModel { // Example domain model
    let id: Int64
    let name: String
}

// MARK: - 2. Database Mappable Protocol
// A protocol to bridge the gap between the database models and domain models.

protocol DatabaseMappable {
    /// The associated GRDB-specific model (DTO).
    associatedtype DTO: FetchableRecord & TableRecord
    
    /// Initializes a domain model from a DTO.
    init(from dto: DTO)
}

// MARK: - 3. Database Models (DTOs)
// These models are specific to your GRDB persistence layer.

struct MyDomainModelDTO: Codable, FetchableRecord, TableRecord {
    let id: Int64
    let name: String

    static var databaseTableName: String { "my_domain_model" }
}

// MARK: - 4. Mapping
// Your domain model conforms to `DatabaseMappable` to define the mapping.

extension MyDomainModel: DatabaseMappable {
    typealias DTO = MyDomainModelDTO
    
    init(from dto: MyDomainModelDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}

// MARK: - 5. Database Service

enum AppError: Error {
    case databaseError(Error)
    case notFound
}

protocol DatabaseService {
    /// Fetches an array of domain models.
    /// The request is a GRDB query on the DTO associated with the domain model.
    func fetch<T: DatabaseMappable>(_ request: QueryInterfaceRequest<T.DTO>) -> SignalProducer<[T], AppError>

//    var allJobs: Signal<[Job], Never>
}

class DefaultDatabaseService: DatabaseService {
    private let dbQueue: DatabaseQueue
//    let allJobs: Signal<[Job], Never>
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func fetch<T: DatabaseMappable>(_ request: QueryInterfaceRequest<T.DTO>) -> SignalProducer<[T], AppError> {

        return SignalProducer { [dbQueue] observer, lifetime in
            do {
                // Fetch DTOs from the database
                let dtos = try dbQueue.read { db in
                    try request.fetchAll(db)
                }
                // Map DTOs to domain models
                let models = dtos.map(T.init)
                
                observer.send(value: models)
                observer.sendCompleted()
            } catch {
                observer.send(error: .databaseError(error))
            }
        }
    }
}

// MARK: - Mock Service for UI Previews and Testing

class MockDatabaseService: DatabaseService {
    
    func fetch<T: DatabaseMappable>(_ request: QueryInterfaceRequest<T.DTO>) -> SignalProducer<[T], AppError> {
        // Check if the fetch request is for Jobs.
        if T.self == Job.self {
            let sampleJobs = [
                Job(id: UUID(), title: "Install new HVAC unit", status: "Scheduled"),
                Job(id: UUID(), title: "Repair leaking pipe", status: "In Progress"),
                Job(id: UUID(), title: "Quarterly generator maintenance", status: "Completed"),
                Job(id: UUID(), title: "Fix faulty wiring", status: "Scheduled")
            ] as! [T] // Force cast to the generic type T

            // Return a producer that immediately sends the sample jobs and completes.
            return SignalProducer(value: sampleJobs)
        }
        
        // For any other type, return an empty array.
        return SignalProducer(value: [])
    }
}