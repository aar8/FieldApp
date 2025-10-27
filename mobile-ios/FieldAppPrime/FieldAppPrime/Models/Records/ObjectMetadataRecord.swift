import Foundation
import GRDB

/// Represents a row in the `object_metadata` database table.
struct ObjectMetadataRecord: Codable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let objectName: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let data: ObjectMetadataData

    static let databaseTableName = "object_metadata"

    enum CodingKeys: String, CodingKey {
        case id, data, version
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension ObjectMetadataRecord {
    /// Maps an `ObjectMetadataRecord` to the `ObjectMetadata` domain model.
    var domainModel: ObjectMetadata {
        return ObjectMetadata(
            id: self.id,
            objectName: self.objectName,
            fieldDefinitions: self.data.fieldDefinitions
        )
    }
}