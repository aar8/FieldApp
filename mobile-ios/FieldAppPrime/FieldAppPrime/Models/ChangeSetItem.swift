import Foundation

/// Represents a single item in a sync request changeset.
/// This is the network model, containing the original overlay data plus the cryptographic hashes required for verification by the server.
struct ChangeSetItem: Codable {
    let id: String
    let tenantId: String
    let objectId: String
    let objectName: String
    let changes: Data
    let createdAt: String // Transmitted as an ISO 8601 string
    
    let stateHash: String
    let previousStateHash: String

    enum CodingKeys: String, CodingKey {
        case id
        case tenantId = "tenant_id"
        case objectId = "object_id"
        case objectName = "object_name"
        case changes
        case createdAt = "created_at"
        case stateHash = "state_hash"
        case previousStateHash = "previous_state_hash"
    }
}
