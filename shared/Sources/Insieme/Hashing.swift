import Foundation
import Crypto

public struct Hashing {
    public static func calculateStateHash(changeHash: String, previousStateHash: String) -> String {
        let combinedHashData = "\(changeHash)\(previousStateHash)"
        let hash = SHA256.hash(data: Data(combinedHashData.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    public static func calculateChangeHash(
        id: String,
        tenantId: String,
        userId: String,
        createdAt: String,
        objectName: String,
        objectId: String,
        changes: String
    ) -> String {
        let changeToHash = "\(id)\(tenantId)\(userId)\(createdAt)\(objectName)\(objectId)\(changes)"
        let hash = SHA256.hash(data: Data(changeToHash.utf8))
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}