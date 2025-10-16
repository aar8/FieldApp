import Foundation
import GRDB

// MARK: - Persistence-Layer Data Models

/// The structure of the 'data' column in the 'jobs' table.
/// This mirrors the structure from the API's SyncResponse.

// MARK: - Job Record (DTO)

/// The `JobRecord` struct represents a row in the `jobs` database table.
/// It conforms to GRDB protocols and handles the direct database interaction.
struct JobRecord: Identifiable, FetchableRecord, TableRecord, Decodable {    
    let id: Int
    var tenantId: String
    var objectType: String
    var status: String
    var data: APIJobData
    var version: Int
    var createdAt: Date
    var updatedAt: Date

    static let databaseTableName = "jobs"
    
    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case tenantId = "tenant_id"
        case objectType = "object_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// Maps a `JobRecord` from the database to a clean `Job` domain model.
    func toDomainModel() -> Job {
        // This is the mapping layer between the persistence model and the domain model.
        let domainData = JobDomainData(title: data.notes, description: nil) // Using notes as title
        
        return Job(
            id: id,
            tenantId: tenantId,
            objectType: objectType,
            status: status,
            data: domainData,
            version: version,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
