import Foundation

public struct ChangeSetItem: Codable {
    public let id: String
    public let tenantId: String
    public let objectId: String
    public let objectName: String
    public let changes: Data
    public let createdAt: String // Transmitted as an ISO 8601 string
    
    public let stateHash: String
    public let previousStateHash: String

    public enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case objectId = "object_id"
        case objectName = "object_name"
        case changes
        case createdAt = "created_at"
        case stateHash = "state_hash"
        case previousStateHash = "previous_state_hash"
    }

    public init(id: String, tenantId: String, objectId: String, objectName: String, changes: Data, createdAt: String, stateHash: String, previousStateHash: String) {
        self.id = id
        self.tenantId = tenantId
        self.objectId = objectId
        self.objectName = objectName
        self.changes = changes
        self.createdAt = createdAt
        self.stateHash = stateHash
        self.previousStateHash = previousStateHash
    }

    // Decode `changes` from either raw Data or a JSON object/string
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        tenantId = try container.decode(String.self, forKey: .tenantId)
        objectId = try container.decode(String.self, forKey: .objectId)
        objectName = try container.decode(String.self, forKey: .objectName)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        stateHash = try container.decode(String.self, forKey: .stateHash)
        previousStateHash = try container.decode(String.self, forKey: .previousStateHash)

        if let data = try? container.decode(Data.self, forKey: .changes) {
            changes = data
        } else if let dict = try? container.decode([String: CodableValue].self, forKey: .changes) {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(dict)
            changes = jsonData
        } else if let str = try? container.decode(String.self, forKey: .changes), let data = str.data(using: .utf8) {
            changes = data
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .changes,
                in: container,
                debugDescription: "Unsupported type for changes. Expected Data, JSON object, or JSON string."
            )
        }
    }
}
