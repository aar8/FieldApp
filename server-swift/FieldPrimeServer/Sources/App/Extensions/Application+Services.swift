import Vapor

// This extension provides a convenient way to access application-wide services.
// It uses Vapor's `Storage` to hold a `Services` struct, which contains
// all the services the application needs. This avoids having to pass service
// instances around manually.
extension Application {
    private struct ServicesKey: StorageKey {
        typealias Value = AppServices
    }

    var services: AppServices {
        get {
            guard let services = self.storage[ServicesKey.self] else {
                fatalError("Services not configured. Use app.services = ...")
            }
            return services
        }
        set {
            self.storage[ServicesKey.self] = newValue
        }
    }

    struct AppServices {
        let database: DatabaseService
    }
}