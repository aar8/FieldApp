import Foundation
import GRDB
import Insieme

struct OverlayRecord: Codable, PersistableRecord, FetchableRecord {
    let id: String
    let tenantId: String
    let objectId: String
    let objectName: String
    let changes: Data
    let createdAt: Date

    static let databaseTableName = "overlays"

    enum CodingKeys: String, CodingKey {
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