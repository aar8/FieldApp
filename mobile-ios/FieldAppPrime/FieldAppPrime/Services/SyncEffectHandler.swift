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
                print(effectResult)
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
            guard let hostURL = metadataService.hostURL else {
                return .failure(.resyncFailed(.missingURL))
            }
            guard let tenantID = metadataService.tenantID else {
                return .failure(.resyncFailed(.missingTenantID))
            }

            let syncResult = await apiService.performResync(host: hostURL, tenantID: tenantID, since: lastModified)
            return syncResult.map { .resyncSuccessful($0) }
                .mapError { .resyncFailed(.apiError($0)) }
            
        case .upsertDB(let syncResponse):
            // TODO: hand this reponse to the db or some other layer this is too much for the effect
            // handler which does not own this domain.
            // 1. Map API models to persistence models
            let jobRecords = syncResponse.data.jobs.map { apiJob -> JobRecord in
                JobRecord(
                    id: apiJob.id,
                    tenantId: apiJob.tenantId,
                    objectName: "job",
                    objectType: apiJob.objectType,
                    status: apiJob.status,
                    version: apiJob.version,
                    createdBy: apiJob.createdAt,
                    modifiedBy: apiJob.updatedAt,
                    createdAt: apiJob.createdAt,
                    updatedAt: apiJob.updatedAt,
                    data: apiJob.data
                )
            }
            
            // 2. Hand off to the database service
            let result = databaseService.upsert(jobs: jobRecords)
            
            // 3. Return the result of the upsert operation
            switch result {
            case .success:
                return .success(.upsertDBSuccessful)
            case .failure(let error):
                print(error)
                return .failure(.upsertDBFailed)
            }

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
