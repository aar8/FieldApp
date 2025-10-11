import Foundation
import ReactiveSwift

struct SyncResult: Codable {
    let summary: Summary
    let conflicts: [SyncConflict]

    struct Summary: Codable {
        let appliedChanges: Int
        let pendingChanges: Int
        let lastSyncedAt: Date
    }
}

struct SyncConflict: Codable {
    let entity: String
    let entityId: String
    let reason: String
}

enum SyncError: Error {
    case transport(underlying: Error)
    case decoding
    case persistence(details: String)
}

protocol SyncNetworking {
    func requestSync(payload: Data) -> SignalProducer<Data, SyncError>
}

protocol SyncPersistence {
    func apply(snapshot: Data) -> SignalProducer<Void, SyncError>
}

protocol DomainMapper {
    func domainModels() -> SignalProducer<[JobViewModel], Never>
}

struct JobViewModel {
    let id: String
    let customerName: String
    let status: String
    let scheduledStart: Date?
    let scheduledEnd: Date?
}

final class FieldPrimePipeline {
    private let networking: SyncNetworking
    private let persistence: SyncPersistence
    private let mapper: DomainMapper

    init(networking: SyncNetworking, persistence: SyncPersistence, mapper: DomainMapper) {
        self.networking = networking
        self.persistence = persistence
        self.mapper = mapper
    }

    func sync(payload: Data) -> SignalProducer<SyncResult, SyncError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        return networking.requestSync(payload: payload)
            .start(on: QueueScheduler(qos: .userInitiated, name: "app.fieldprime.sync"))
            .attemptMap { data -> Result<SyncResult, SyncError> in
                guard let result = try? decoder.decode(SyncResult.self, from: data) else {
                    return .failure(.decoding)
                }
                return .success(result)
            }
            .flatMap(.concat) { [persistence] result -> SignalProducer<SyncResult, SyncError> in
                guard let snapshot = try? encoder.encode(result) else {
                    return SignalProducer(error: .decoding)
                }

                return persistence.apply(snapshot: snapshot)
                    .then(SignalProducer(value: result))
            }
            .observe(on: QueueScheduler(qos: .background, name: "app.fieldprime.persistence"))
    }

    func jobsStream() -> SignalProducer<[JobViewModel], Never> {
        return mapper.domainModels()
            .observe(on: QueueScheduler.main)
    }
}
