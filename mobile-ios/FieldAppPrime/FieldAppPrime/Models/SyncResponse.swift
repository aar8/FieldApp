import Foundation

// MARK: - Main Response Structure

struct SyncResponse: Decodable {
    let meta: Meta
    let data: DataPayload
}

// MARK: - Meta

struct Meta: Decodable {
    let serverTime: Date
    let since: String

    enum CodingKeys: String, CodingKey {
        case serverTime = "server_time"
        case since
    }
}

// MARK: - Data Payload

struct DataPayload: Decodable {
    let objectMetadata: [[String: AnyDecodable]]
    let layouts: [[String: AnyDecodable]]
    let customers: [APICustomer]
    let jobs: [APIJob]

    enum CodingKeys: String, CodingKey {
        case objectMetadata = "object_metadata"
        case layouts, customers, jobs
    }
}

// MARK: - API Customer Model

struct APICustomer: Decodable {
    let id, objectType, status, tenantID: String
    let createdAt, updatedAt: Date
    let createdBy, modifiedBy: String?
    let version: Int
    let data: CustomerData

    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case objectType = "object_type"
        case tenantID = "tenant_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
    }
}

struct CustomerData: Decodable {
    let name: String
    let contact: Contact
    let address: Address
}

struct Address: Decodable {
    let street, city, state, zip: String
}

struct Contact: Decodable {
    let email, phone: String
}

// MARK: - API Job Model

struct APIJob: Decodable {
    let id: String
    let tenantId: String
    let objectType: String
    let status: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: Date
    let updatedAt: Date
    let data: [String: AnyDecodable] // Using the flexible decoder

    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case tenantId = "tenant_id"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - AnyDecodable Helper

// Helper to decode, and encode, any JSON value.
struct AnyDecodable: Codable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            self.value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            self.value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            self.value = boolValue
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            self.value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyDecodable].self) {
            self.value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(AnyDecodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.value {
        case is NSNull, is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyDecodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyDecodable($0) })
        default:
            throw EncodingError.invalidValue(self.value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyDecodable value cannot be encoded"))
        }
    }
}
