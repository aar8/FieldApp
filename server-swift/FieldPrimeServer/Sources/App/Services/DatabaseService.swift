import GRDB
import Vapor

struct DatabaseService {
    let dbQueue: DatabaseQueue

    init(app: Application) throws {
        let dbPath = Environment.get("SQLITE_PATH") ?? "/app/data/fieldprime.db"
        self.dbQueue = try DatabaseQueue(path: dbPath)
    }
}