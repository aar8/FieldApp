import Vapor

struct AppRoutes: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get { req async in
            "It works!"
        }

        routes.get("hello") { req async -> String in
            "Hello, world!"
        }

        let syncController = SyncController()
        routes.get("sync", use: syncController.sync)
        routes.post("sync", use: syncController.postSync)
    }
}