import Vapor
import GRDB
import Insieme

struct SyncController {
    struct SyncParams: Content {
        let tenant_id: String
        let since: String?
    }

    func sync(req: Request) async throws -> SyncResponse {
        let params = try req.query.decode(SyncParams.self)
        let since = params.since ?? "1970-01-01T00:00:00Z"
        print(params)
        let dbQueue = req.application.services.database.dbQueue

        let responseData = try await dbQueue.read { db in
            try getDataResult(db: db, tenantId: params.tenant_id, since: since)
        }

        let meta = Meta(serverTime: Date().ISO8601Format(), since: since)

        return SyncResponse(meta: meta, data: responseData)
    }

    func postSync(req: Request) async throws -> Response {
        let changeSetItems = try req.content.decode([ChangeSetItem].self)

        if changeSetItems.isEmpty {
            return Response(status: .ok, body: .init(string: "No changes to sync."))
        }

        let dbQueue = req.application.services.database.dbQueue
        let userID = req.headers.first(name: "X-User-ID") ?? "fake_user_from_header"

        try await dbQueue.inTransaction { db in
            let tenantID = changeSetItems[0].tenantId
            
            // Preflight: Validate tenant and user
            guard let tenantCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM tenants WHERE id = ?", arguments: [tenantID]), tenantCount > 0 else {
                throw Abort(.badRequest, reason: "Provided tenant_id does not exist.")
            }
            guard let userCount = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM users WHERE id = ?", arguments: [userID]), userCount > 0 else {
                throw Abort(.badRequest, reason: "X-User-ID does not refer to an existing user.")
            }

            var currentChainHead = try String.fetchOne(db, sql: "SELECT state_hash FROM change_log WHERE tenant_id = ? ORDER BY sequence_id DESC LIMIT 1", arguments: [tenantID]) ?? "0000000000000000000000000000000000000000000000000000000000000000"

            for item in changeSetItems {
                if item.objectName != "job" { continue }

                if item.previousStateHash != currentChainHead {
                    throw Abort(.conflict, reason: "Client history has diverged or batch is inconsistent. Please sync first.")
                }

                let changesString = String(data: item.changes, encoding: .utf8)!

                let changeHash = Hashing.calculateChangeHash(
                    id: item.id,
                    tenantId: item.tenantId,
                    userId: userID,
                    createdAt: item.createdAt,
                    objectName: item.objectName,
                    objectId: item.objectId,
                    changes: changesString
                )

                let serverCalculatedHash = Hashing.calculateStateHash(
                    changeHash: changeHash,
                    previousStateHash: item.previousStateHash
                )

                if serverCalculatedHash != item.stateHash {
                    throw Abort(.badRequest, reason: "Client hash does not match server calculation.")
                }

                try db.execute(
                    sql: "INSERT INTO change_log (id, tenant_id, user_id, object_name, record_id, change_data, state_hash, previous_state_hash, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    arguments: [item.id, item.tenantId, userID, item.objectName, item.objectId, changesString, item.stateHash, item.previousStateHash, item.createdAt]
                )

                try db.execute(
                    sql: "UPDATE jobs SET data = json_patch(data, ?), version = version + 1, updated_at = ? WHERE id = ?",
                    arguments: [changesString, item.createdAt, item.objectId]
                )

                if db.changesCount == 0 {
                    try db.execute(
                        sql: "INSERT INTO jobs (id, tenant_id, status, version, created_by, modified_by, created_at, updated_at, object_name, object_type, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        arguments: [item.objectId, item.tenantId, "active", 0, userID, userID, item.createdAt, item.createdAt, item.objectName, item.objectName, changesString]
                    )
                }
                
                currentChainHead = item.stateHash
            }
            return .commit
        }

        return Response(status: .ok, body: .init(string: "ok"))
    }
}