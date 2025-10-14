import Foundation

/// Defines a standard interface for reading and writing metadata required for synchronization.
///
/// This protocol abstracts the underlying storage mechanism (e.g., UserDefaults, a database, a file)
/// to allow for easier platform porting and future refactoring.
protocol SyncMetadataService {
    /// The timestamp of the last successful synchronization, typically in ISO8601 format.
    /// A `nil` value indicates that a sync has never completed successfully.
    var lastSyncTimestamp: String? { get set }
}


/// An implementation of `SyncMetadataService` that uses `UserDefaults` as the backing store.
class UserDefaultsSyncMetadataService: SyncMetadataService {

    private let userDefaults: UserDefaults
    
    // A namespaced key to prevent collisions in UserDefaults.
    private static let lastSyncTimestampKey = "com.fieldapp.sync.lastSyncTimestamp"

    /// Initializes the service with a specific UserDefaults instance.
    /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var lastSyncTimestamp: String? {
        get {
            // Retrieve the string value from UserDefaults.
            return userDefaults.string(forKey: Self.lastSyncTimestampKey)
        }
        set {
            // Set the new value in UserDefaults.
            // If `newValue` is nil, it removes the key-value pair.
            userDefaults.set(newValue, forKey: Self.lastSyncTimestampKey)
        }
    }
}
