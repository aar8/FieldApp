import Foundation

/// A protocol defining the interface for making network calls to the main server API.
protocol APIService {
    // In the future, this would define methods for network calls, e.g.:
    // func performResync(lastModified: String?) async throws -> (String, Data)
}

/// A mock implementation of APIService that can be used for SwiftUI previews or testing.
class DefaultAPIService: APIService {
    // This class can be expanded to return mock data for different API calls.
}
