import Foundation
import GRDB

/// Represents a row in the `layout_definitions` database table.
struct LayoutDefinitionRecord: Codable, FetchableRecord, PersistableRecord {
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
    let data: LayoutDefinitionData

    static let databaseTableName = "layout_definitions"

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

extension LayoutDefinitionRecord {
    /// Maps a `LayoutDefinitionRecord` to the `LayoutDefinition` domain model.
    var domainModel: LayoutDefinition {
        return LayoutDefinition(
            id: self.id,
            objectName: self.objectName,
            objectType: self.objectType,
            status: self.status,
            sections: self.data.sections
        )
    }
}
