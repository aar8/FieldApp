import Foundation
import GRDB

// MARK: - Job Record (DTO)

/// The `JobRecord` struct represents a row in the `jobs` database table.
struct JobRecord: Codable, FetchableRecord, PersistableRecord {
    let id: String
    var tenantId: String
    var objectType: String
    var status: String
    let data: [String: AnyDecodable]
    var version: Int
    var createdBy: String?
    var modifiedBy: String?
    var createdAt: Date
    var updatedAt: Date

    static let databaseTableName = "jobs"
    
    enum CodingKeys: String, CodingKey {
        case id
        case data
        case version
        case status
        case tenantId = "tenant_id"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // GRDB needs this custom encoder to map to snake_case columns
    // when a custom encode(to: PersistenceContainer) is not provided.
    // Since we don't need a custom encoder anymore, this ensures correct mapping.

    /// Maps a `JobRecord` from the database to a clean `Job` domain model.
    func toDomainModel() -> Job {
        // TODO: Decode the 'data' JSON string to populate the domain model correctly.
        let domainData = JobDomainData(title: "Title (from JSON)", description: nil)
        
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
