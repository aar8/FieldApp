import SwiftUI

@main
struct FieldAppPrimeApp: App {
    
    // MARK: - Services
    private let apiService: APIService
    private let databaseService: DatabaseService
    private let webSocketService: WebSocketService
    private let metadataService: SyncMetadataService
    private let syncEffectHandler: SyncEffectHandler
    private let syncCoordinator: SyncCoordinator
    
    // MARK: - Factories
    private let viewFactory: ViewFactory

    init() {
        // --- Service Initialization ---
        // In a real app, you might use a more advanced DI container.

        // 1. Standalone Services
        let apiService = DefaultAPIService()
        let webSocketService = DefaultWebSocketService()
        let metadataService = UserDefaultsSyncMetadataService()
        let databaseService = MockDatabaseService() // Using mock for UI development

        // 2. Composite Services
        let syncEffectHandler = SyncEffectHandlerImpl(
            apiService: apiService,
            databaseService: databaseService,
            webSocketService: webSocketService,
            metadataService: metadataService
        )

        // 3. The Main Coordinator
        let syncCoordinator = SyncCoordinator(effectHandler: syncEffectHandler)
        
        // 4. The View Factory
        let viewFactory = ViewFactory(databaseService: databaseService)

        // 5. Assign to self
        self.apiService = apiService
        self.databaseService = databaseService
        self.webSocketService = webSocketService
        self.metadataService = metadataService
        self.syncEffectHandler = syncEffectHandler
        self.syncCoordinator = syncCoordinator
        self.viewFactory = viewFactory
    }

    var body: some Scene {
        WindowGroup {
            // The factory is passed to the root view, which can then use it
            // to create any subviews it needs.
            ContentView(viewFactory: viewFactory)
        }
    }
}
