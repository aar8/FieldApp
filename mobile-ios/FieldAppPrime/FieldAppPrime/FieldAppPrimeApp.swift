import SwiftUI

@main
struct FieldAppPrimeApp: App {
    
    // MARK: - Services
    private let appDatabase: AppDatabaseProtocol
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

        // 1. Initialize the database and hold a strong reference to it.
        let appDatabase: AppDatabaseProtocol
        switch AppDatabase.create() {
        case .success(let database):
            appDatabase = database
        case .failure(let error):
            fatalError("Failed to initialize database: \(error)")
        }
        self.appDatabase = appDatabase

        // 2. Standalone Services
        let apiService = DefaultAPIService()
        let webSocketService = DefaultWebSocketService()
        let metadataService = UserDefaultsSyncMetadataService()
        let databaseService = DefaultDatabaseService(appDatabase: appDatabase)

        // 3. Composite Services
        let syncEffectHandler = SyncEffectHandlerImpl(
            apiService: apiService,
            databaseService: databaseService,
            webSocketService: webSocketService,
            metadataService: metadataService
        )

        // 4. The Main Coordinator
        let syncCoordinator = SyncCoordinator(effectHandler: syncEffectHandler)
        
        // 5. The View Factory
        let viewFactory = ViewFactory(databaseService: databaseService)

        // 6. Assign to self
        self.apiService = apiService
        self.databaseService = databaseService
        self.webSocketService = webSocketService
        self.metadataService = metadataService
        self.syncEffectHandler = syncEffectHandler
        self.syncCoordinator = syncCoordinator
        self.viewFactory = viewFactory

        metadataService.hostURL = URL(string: "http://localhost:8080")
        metadataService.tenantID = "7f33e4b0-2ba2-4084-bbda-57d6268d7ccb"
        
        syncCoordinator.foreground()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewFactory: viewFactory)
        }
    }
}
