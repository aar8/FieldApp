import Foundation
import GRDB

/// Represents a single job record in the system.
struct Job: Identifiable {
    let id: UUID
    let title: String
    let status: String
}

// MARK: - Database Mapping

/// The DTO (Data Transfer Object) for a Job, used for database persistence with GRDB.
struct JobDTO: Codable, FetchableRecord, TableRecord {
    let id: String
    let title: String
    let status: String

    static var databaseTableName: String { "job" }
}

/// Conformance to allow mapping from the database DTO to the domain model.
extension Job: DatabaseMappable {
    typealias DTO = JobDTO
    
    init(from dto: JobDTO) {
        self.id = UUID(uuidString: dto.id) ?? UUID()
        self.title = dto.title
        self.status = dto.status
    }
}
