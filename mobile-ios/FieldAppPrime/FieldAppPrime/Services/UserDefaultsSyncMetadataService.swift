import Foundation
import SyncClient

/// An implementation of `SyncMetadataService` that uses `UserDefaults` as the backing store.
class UserDefaultsSyncMetadataService: SyncMetadataService {

    private let userDefaults: UserDefaults
    
    // A namespaced key to prevent collisions in UserDefaults.
    private static let lastSyncTimestampKey = "com.fieldapp.sync.lastSyncTimestamp"
    private static let hostURLKey = "com.fieldapp.sync.hostURL"
    private static let tenantIDKey = "com.fieldapp.sync.tenantID"

    /// Initializes the service with a specific UserDefaults instance.
    /// - Parameter userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var lastSyncTimestamp: String? {
        get {
            return userDefaults.string(forKey: Self.lastSyncTimestampKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.lastSyncTimestampKey)
        }
    }
    
    var hostURL: URL? {
        get {
            return userDefaults.url(forKey: Self.hostURLKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hostURLKey)
        }
    }
    
    var tenantID: String? {
        get {
            return userDefaults.string(forKey: Self.tenantIDKey)
        }
        set {
            userDefaults.set(newValue, forKey: Self.tenantIDKey)
        }
    }
}
