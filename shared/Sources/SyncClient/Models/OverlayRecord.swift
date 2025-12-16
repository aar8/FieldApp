import Foundation
import GRDB
import Insieme

public struct OverlayRecord: Codable, PersistableRecord, FetchableRecord {
    public let id: String
    public let tenantId: String
    public let objectId: String
    public let objectName: String
    public let changes: Data
    public let createdAt: Date

    public static let databaseTableName = "overlays"

    public enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case objectId = "object_id"
        case objectName = "object_name"
        case changes
        case createdAt = "created_at"
    }
}

extension OverlayRecord {
    func toPendingChange() -> PendingChange {
        .init(
            id: self.id,
            tenantId: self.tenantId,
            objectId: self.objectId,
            objectName: self.objectName,
            changes: self.changes,
            createdAt: self.createdAt
        )
    }
}
