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

    func effectCompleted(callback: @escaping (Result<SyncEffectResult, SyncEffectError>) -> Void) {
        self.completionHandler = callback
    }

    // This method is called by the SyncCoordinator to execute a side effect.
    func runEffect(syncEffect: SyncEffect)  {
        Task {
            // Ensure the completion handler has been set before proceeding.
            guard let completionHandler = completionHandler else {
                print("SyncEffectHandler Error: completionHandler was not set by the coordinator!")
                return
            }
            
            if let effectResult = await result(for: syncEffect) {
                completionHandler(effectResult)
            }
        }
    }

    private func result(for syncEffect: SyncEffect) async -> Result<SyncEffectResult, SyncEffectError>? {
        switch syncEffect {
        case .sleep(let duration):
            let nanoseconds: UInt64 = UInt64(duration) * 1_000_000_000
            try? await Task.sleep(nanoseconds: nanoseconds)
            
            return .success(.sleepSuccessful)
        case .readLastModified:
            let lastModified = metadataService.lastSyncTimestamp
            return .success(.readLastModifiedSuccessful(lastModified))

        case .resync(let lastModified):
            let responseData = "{\"message\":\"fake server data\"}".data(using: .utf8)!
            return .success(.resyncSuccessful("new_sync_token", responseData))
            
        case .upsertDB(let data):
            return .success(.upsertDBSuccessful)

        case .openWebSocket:
            return .success(.openWebSocketSuccessful)

        case .sendPing:
            return .success(.sendPingSuccessful)

        case .closeWebSocket:
            return .success(.closeWebSocketSuccessful)
            
        case .nullEffect:
            return nil
        }
    }
}
