import Vapor
import NIOCore

@main
struct App {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let app = try await Application.make(env, .shared(group))

        do {
            try await configure(app)
            try await app.execute()
        } catch {
            app.logger.critical("SERVER EXITED WITH ERROR: \(error)")
            throw error
        }
    }
}

func configure(_ app: Application) async throws {
    // Initialize services
    let dbService = try DatabaseService(app: app)
    app.services = .init(database: dbService)

    // register routes
    try app.register(collection: AppRoutes())
}