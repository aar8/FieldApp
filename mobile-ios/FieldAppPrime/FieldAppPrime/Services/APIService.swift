import Foundation

// MARK: - Result+Async Initializer

extension Result where Failure == Swift.Error {
    /// Creates a new result by evaluating an async throwing closure,
    /// capturing the returned value as a success, or the thrown error as a failure.
    init(catching body: () async throws -> Success) async {
        do {
            let value = try await body()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
}

// MARK: - API Service

/// Defines errors that can occur during API interactions.
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
}

/// A protocol defining the interface for making network calls to the main server API.
protocol APIService {
    func performResync(host: URL, tenantID: String, since: String?) async -> Result<SyncResponse, APIError>
}

/// The default implementation of APIService that uses URLSession to perform network requests.
class DefaultAPIService: APIService {

    func performResync(host: URL, tenantID: String, since: String?) async -> Result<SyncResponse, APIError> {
        guard let url = makeSyncURL(host: host, tenantID: tenantID, since: since) else {
            return .failure(.invalidURL)
        }

        return await fetchData(from: url)
            .flatMap(self.decodeSyncResponse)
    }

    private func makeSyncURL(host: URL, tenantID: String, since: String?) -> URL? {
        guard var components = URLComponents(url: host.appendingPathComponent("sync"), resolvingAgainstBaseURL: false) else {
            return nil
        }

        var queryItems = [URLQueryItem(name: "tenant_id", value: tenantID)]
        if let since = since {
            queryItems.append(URLQueryItem(name: "since", value: since))
        }
        components.queryItems = queryItems

        return components.url
    }

    private func fetchData(from url: URL) async -> Result<Data, APIError> {
        let result = await Result<Data, Error> {
            try await URLSession.shared.data(from: url).0
        }
        return result.mapError { .networkError($0) }
    }

    private func decodeSyncResponse(from data: Data) -> Result<SyncResponse, APIError> {
        let result = Result<SyncResponse, Error> {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(SyncResponse.self, from: data)
        }
        
        return result.mapError { .decodingError($0) }
    }
}
