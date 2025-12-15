import Foundation

public struct ChangeSetCalculator {
    
    public static func createChangeSet(
        from pendingChanges: [PendingChange],
        previousStateHash: String,
        userId: String
    ) -> [ChangeSetItem] {
        
        var currentPreviousHash = previousStateHash
        var changeSetItems: [ChangeSetItem] = []
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        for change in pendingChanges {
            let createdAtString = isoFormatter.string(from: change.createdAt)
            
            // To create a canonical string for hashing, we decode the `changes` data,
            // sort it by key, and then re-serialize it into a stable string format.
            let stableChangesString: String
            if let changesDict = try? JSONDecoder().decode([String: CodableValue].self, from: change.changes) {
                let sortedKeys = changesDict.keys.sorted()
                stableChangesString = sortedKeys.map { key in
                    let value = changesDict[key]! // Force unwrap is safe because we just got the keys
                    return "\(key):\(String(describing: value.value))"
                }.joined(separator: ";")
            } else {
                // Fallback for non-dictionary data, which shouldn't happen for patch-based changes.
                stableChangesString = String(data: change.changes, encoding: .utf8) ?? ""
            }

            // --- Hash Calculation using shared Hashing module ---
            
            let changeHash = Hashing.calculateChangeHash(
                id: change.id,
                tenantId: change.tenantId,
                userId: userId,
                createdAt: createdAtString,
                objectName: change.objectName,
                objectId: change.objectId,
                changes: stableChangesString
            )
            
            let newStateHash = Hashing.calculateStateHash(
                changeHash: changeHash,
                previousStateHash: currentPreviousHash
            )

            // Create the network-ready ChangeSetItem.
            let item = ChangeSetItem(
                id: change.id,
                tenantId: change.tenantId,
                objectId: change.objectId,
                objectName: change.objectName,
                changes: change.changes,
                createdAt: createdAtString,
                stateHash: newStateHash,
                previousStateHash: currentPreviousHash
            )
            changeSetItems.append(item)
            
            // The new hash becomes the previous hash for the next item in the batch.
            currentPreviousHash = newStateHash
        }
        
        return changeSetItems
    }
}
