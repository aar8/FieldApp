import Foundation
import ReactiveSwift


protocol SyncEffectHandler {
    func runEffect(syncEffect: SyncEffect)
    func effectCompleted(callback: @escaping (Result<SyncEffectResult, SyncEffectError>)->())
}

class SyncEffectHandlerImpl: SyncEffectHandler {
    private let apiService: APIService
    private let databaseService: DatabaseService
    private let webSocketService: WebSocketService
    private let metadataService: SyncMetadataService
    
    private var completionHandler: ((Result<SyncEffectResult, SyncEffectError>) -> Void)?

    // --- Initializer ---
    init(
        apiService: APIService,
        databaseService: DatabaseService,
        webSocketService: WebSocketService,
        metadataService: SyncMetadataService
    ) {
        self.apiService = apiService
        self.databaseService = databaseService
        self.webSocketService = webSocketService
        self.metadataService = metadataService
    }

    // The SyncCoordinator calls this once at startup to register its callback.
    func effectCompleted(callback: @escaping (Result<SyncEffectResult, SyncEffectError>) -> Void) {
        self.completionHandler = callback
    }

    // This method is called by the SyncCoordinator to execute a side effect.
    func runEffect(syncEffect: SyncEffect) {
        // Ensure the completion handler has been set before proceeding.
        guard let completionHandler = completionHandler else {
            print("SyncEffectHandler Error: completionHandler was not set by the coordinator!")
            return
        }

        print("--- Running Effect: \(syncEffect) ---")

        switch syncEffect {
        
        case .sleep(let duration):
            // TODO: Implement a real async sleep, e.g., DispatchQueue.main.asyncAfter
            print("EFFECT: Pretending to sleep for \(duration) seconds.")
            completionHandler(.success(.sleepSuccessful))

        case .readLastModified:
            // TODO: Use metadataService to get the last modified timestamp.
            print("EFFECT: Reading last modified timestamp from local DB.")
            let fakeTimestamp = ISO8601DateFormatter().string(from: Date())
            completionHandler(.success(.readLastModifiedSuccessful(fakeTimestamp)))

        case .resync(let lastModified):
            // TODO: Use apiService to make the resync network call.
            print("EFFECT: Calling resync endpoint (last modified: \(lastModified ?? "none")).")
            let responseData = "{\"message\":\"fake server data\"}".data(using: .utf8)!
            completionHandler(.success(.resyncSuccessful("new_sync_token", responseData)))
            
        case .upsertDB(let data):
            // TODO: Use databaseService to perform the write operation.
            print("EFFECT: Upserting \(data.count) bytes to the database.")
            completionHandler(.success(.upsertDBSuccessful))

        case .openWebSocket:
            // TODO: Use webSocketService to connect.
            print("EFFECT: Opening WebSocket connection.")
            completionHandler(.success(.openWebSocketSuccessful))

        case .sendPing:
            // TODO: Use webSocketService to send a ping.
            print("EFFECT: Sending WebSocket ping.")
            completionHandler(.success(.sendPingSuccessful))

        case .closeWebSocket:
            // TODO: Use webSocketService to disconnect.
            print("EFFECT: Closing WebSocket connection.")
            completionHandler(.success(.closeWebSocketSuccessful))
            
        case .nullEffect:
            // This effect intentionally does nothing. We don't call the completion
            // handler because that would trigger an unnecessary state machine cycle.
            print("EFFECT: Null effect. Doing nothing.")
            break
        }
    }
}
