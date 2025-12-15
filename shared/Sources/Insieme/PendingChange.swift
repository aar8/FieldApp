import Foundation

public struct PendingChange {
    public let id: String
    public let tenantId: String
    public let objectId: String
    public let objectName: String
    public let changes: Data
    public let createdAt: Date

    public init(id: String, tenantId: String, objectId: String, objectName: String, changes: Data, createdAt: Date) {
        self.id = id
        self.tenantId = tenantId
        self.objectId = objectId
        self.objectName = objectName
        self.changes = changes
        self.createdAt = createdAt
    }
}
