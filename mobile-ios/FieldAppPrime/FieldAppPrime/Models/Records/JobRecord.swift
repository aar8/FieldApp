import Foundation
import GRDB

/// Represents a row in the `jobs` database table, conforming to GRDB protocols.
struct JobRecord: Codable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let objectName: String
    let objectType: String
    let status: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let data: JobData // Uses the Codable struct from SyncResponse.swift

    // Explicitly tells GRDB to use the "jobs" table for this record.
    static let databaseTableName = "jobs"

    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// The mapping function to the domain model.
extension JobRecord {
    /// Maps a `JobRecord` from the database to a clean `Job` domain model.
    var domainModel: Job {
        return Job(
            id: self.id,
            status: self.status,
            version: self.version,
            updatedAt: self.updatedAt,
            jobNumber: self.data.jobNumber,
            customerId: self.data.customerId,
            jobAddress: self.data.jobAddress,
            jobDescription: self.data.jobDescription,
            assignedTechId: self.data.assignedTechId,
            statusNote: self.data.statusNote
        )
    }
}
