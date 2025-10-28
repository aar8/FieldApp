import Foundation
import GRDB

/// A protocol for data structures that can be contained within a generic `DatabaseRecord`.
/// It requires the conforming type to specify the database table it belongs to.
protocol DataType: Codable, Hashable {
    static var databaseTableName: String { get }
}

/// A generic database record that wraps a specific data type (`JobData`, `CustomerData`, etc.).
/// It conforms to GRDB's protocols for database operations.
struct DatabaseRecord<T: DataType>: Codable, FetchableRecord, PersistableRecord, Hashable {
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
    let data: T

    static var databaseTableName: String { T.databaseTableName }

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
