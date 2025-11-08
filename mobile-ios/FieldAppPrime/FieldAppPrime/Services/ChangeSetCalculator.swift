import Foundation
import CryptoKit

struct ChangeSetCalculator {
    
    /// Takes a list of locally stored overlays and transforms them into a verifiable, chained list of `ChangeSetItem`s ready for syncing.
    /// - Parameters:
    ///   - overlays: The array of `OverlayRecord`s fetched from the local database.
    ///   - previousStateHash: The last state hash received from the server from the previous successful sync.
    ///   - userId: The ID of the current user.
    /// - Returns: An array of `ChangeSetItem`s with a verified hash chain.
    static func createChangeSet(
        from overlays: [OverlayRecord],
        previousStateHash: String,
        userId: String
    ) -> [ChangeSetItem] {
        
        var currentPreviousHash = previousStateHash
        var changeSetItems: [ChangeSetItem] = []
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for overlay in overlays {
            let createdAtString = isoFormatter.string(from: overlay.createdAt)
            // The `changes` Data needs to be converted to a canonical JSON string (compact, no whitespace).
            // A real implementation should ensure the JSON is canonical (e.g., sorted keys).
            // For now, a standard string representation is a good starting point.
            let changesJSONString = String(data: overlay.changes, encoding: .utf8) ?? ""

            // --- Hash Calculation ---
            // This logic must exactly match the server's verification logic.
            
            // 1. Create the canonical string to be hashed.
            let changeToHash = "\(overlay.id)\(overlay.tenantId)\(userId)\(createdAtString)\(overlay.objectName)\(overlay.objectId)\(changesJSONString)"
            
            guard let changeData = changeToHash.data(using: .utf8) else {
                // This should never fail. If it does, it's a programmer error.
                fatalError("Failed to convert canonical string to data for hashing.")
            }
            
            // 2. Create the inner hash.
            let innerHash = SHA256.hash(data: changeData).compactMap { String(format: "%02x", $0) }.joined()
            
            // 3. Create the outer hash.
            let combinedHashDataString = "\(innerHash)\(currentPreviousHash)"
            guard let combinedData = combinedHashDataString.data(using: .utf8) else {
                fatalError("Failed to convert combined hash string to data for hashing.")
            }
            let newStateHash = SHA256.hash(data: combinedData).compactMap { String(format: "%02x", $0) }.joined()

            // 4. Create the network-ready ChangeSetItem.
            let item = ChangeSetItem(
                id: overlay.id,
                tenantId: overlay.tenantId,
                objectId: overlay.objectId,
                objectName: overlay.objectName,
                changes: overlay.changes,
                createdAt: createdAtString,
                stateHash: newStateHash,
                previousStateHash: currentPreviousHash
            )
            changeSetItems.append(item)
            
            // 5. The new hash becomes the previous hash for the next item in the batch.
            currentPreviousHash = newStateHash
        }
        
        return changeSetItems
    }
}
