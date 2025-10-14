
/// ## Post-MVP Enhancements
///
/// 1.  **Interruptible State and Event Queue:** To solve race conditions (e.g., a foreground event
///     arriving during a database write), events should not be processed immediately. Instead, they
///     should be added to a queue. The state machine will consume from this queue only when its
///     current state is "interruptible". The reducer logic will be enhanced to check `canConsume(event)`
///     based on the current state, preventing dangerous interruptions. The queue can also be debounced
///     to avoid redundant work from rapid, consecutive events.
///
/// 2.  **Server Health Heuristic (Circuit Breaker):** A "server health" score will be added to the
///     coordinator's state. Successful syncs and pings will increase the score, while failures
///     will decrease it. The reducers will use this score to dynamically adjust behavior, such as
///     increasing the delay between sync attempts when server health is low, thus acting as a
///     client-side circuit breaker.
/// 
import Foundation
import ReactiveSwift

enum SyncEffectError: Error {
    case readLastModifiedFailed
    case resyncFailed
    case upsertDBFailed
    case openWebSocketFailed
    case sendPingFailed
    case closeWebSocketFailed
}

enum SyncEffect {
    case sleep(Int)
    case readLastModified
    case resync(String?)
    case upsertDB(Data)
    case openWebSocket
    case sendPing
    case closeWebSocket
    case nullEffect
}

enum SyncEffectResult {
    case sleepSuccessful
    case readLastModifiedSuccessful(String)
    case resyncSuccessful(String, Data)
    case upsertDBSuccessful
    case openWebSocketSuccessful
    case sendPingSuccessful
    case closeWebSocketSuccessful
}

enum SyncEvent {
    case foreground
    case background
    case effectResult(Result<SyncEffectResult, SyncEffectError>)
}

enum DisconnectedReason {
    case missedPing
    case initializing
    case webSocketConnectFailed
    case syncFailed
}

enum SyncState {
    case disconnected(DisconnectedReason)
    case resync(wait: Int)
    case initializeWebSocket
    case webSocketConnected
    case disabled
}

class SyncCoordinator {
    // TODO: Add server health heuristic to slow syncs if needed.
    // This state will persist across SyncState changes.
    var currentState: SyncState = .disconnected(.initializing)
    let effectHandler: SyncEffectHandler

    init(effectHandler: SyncEffectHandler) {
        self.effectHandler = effectHandler
        effectHandler.effectCompleted { result in
            self.send(event: .effectResult(result))
        }
    }

    func foreground() {
        send(event: .foreground)
    }

    func background() {
        send(event: .background)
    }

    func send(event: SyncEvent) {
        let syncState = self.currentState
        let (newState, newEffect) =
        switch (event) {
        case .effectResult(let result):
            Self.reduceEffect(syncState, result)
        case .foreground:
            // TODO: this is very dangerous because it may interrupt an upsert need to move this and effect 
            // consumption into queue where state machine can consume based on interrupt-ability of current state
            (.resync(wait: 0), .sleep(0))
        case .background:
            // TODO: this is very dangerous because it may interrupt an upsert need to move this and effect 
            // consumption into queue where state machine can consume based on interrupt-ability of current state
            (.disabled, .nullEffect)
        }
        
        self.currentState = newState
        self.effectHandler.runEffect(syncEffect: newEffect)
    }

    // Pure functions
    static func reduceEffect(_ syncState: SyncState, _ result: Result<SyncEffectResult, SyncEffectError>) ->  (SyncState, SyncEffect) {
        switch result {
        case .success(let value):
            reduceEffectSuccess(syncState, value)
        case .failure(let error):
            reduceEffectFailure(syncState, error)
        }
    }

    static func reduceEffectSuccess(_ syncState: SyncState, _ success: SyncEffectResult) -> (SyncState, SyncEffect) {

        switch (syncState, success) {
            // Web socket closed due to instability
            case (.resync(let t), .closeWebSocketSuccessful):
                (syncState, .sleep(t));

            case (.resync, .sleepSuccessful):
                (syncState, .readLastModified);

            case (.resync, .readLastModifiedSuccessful(let lm)):
                (syncState, .resync(lm));

            case (.resync, .resyncSuccessful):
                (.initializeWebSocket, .openWebSocket);

            case (.initializeWebSocket, .openWebSocketSuccessful):
                (.webSocketConnected, .sendPing);

            case (.webSocketConnected, .sendPingSuccessful):
                (.webSocketConnected, .sleep(30))

            case (.webSocketConnected, .sleepSuccessful):
                (.webSocketConnected, .sendPing)
            default:
                (.disabled, .nullEffect);
        }
    }

    static func reduceEffectFailure(_ syncState: SyncState, _ error: SyncEffectError) -> (SyncState, SyncEffect) {
        // let success: SyncEffectResult = ...
        switch (syncState, error) {
        case (.resync, .readLastModifiedFailed):
            // heavy resync log in new relic
            return (syncState, .resync(nil));

        // shrug? at least send the signal to NR
        case (.resync(let t), .closeWebSocketFailed):
            return (syncState, .sleep(t));

        case (.resync(let wait), .resyncFailed):
                let backoff = wait * 2
            return (.resync(wait: backoff), .sleep(backoff));

        case (.initializeWebSocket, .openWebSocketFailed):
            return (.resync(wait: 5), .sleep(5));

        case (.webSocketConnected, .sendPingFailed):
            return (.resync(wait:5), .closeWebSocket)

        // Explicitly list all other unhandled failure cases to fall back to a disabled state.
        case (.disconnected, .readLastModifiedFailed),
             (.disconnected, .resyncFailed),
             (.disconnected, .upsertDBFailed),
             (.disconnected, .openWebSocketFailed),
             (.disconnected, .sendPingFailed),
             (.disconnected, .closeWebSocketFailed),
             (.resync, .upsertDBFailed),
             (.resync, .openWebSocketFailed),
             (.resync, .sendPingFailed),
             (.initializeWebSocket, .readLastModifiedFailed),
             (.initializeWebSocket, .resyncFailed),
             (.initializeWebSocket, .upsertDBFailed),
             (.initializeWebSocket, .sendPingFailed),
             (.initializeWebSocket, .closeWebSocketFailed),
             (.webSocketConnected, .readLastModifiedFailed),
             (.webSocketConnected, .resyncFailed),
             (.webSocketConnected, .upsertDBFailed),
             (.webSocketConnected, .openWebSocketFailed),
             (.webSocketConnected, .closeWebSocketFailed),
             (.disabled, .readLastModifiedFailed),
             (.disabled, .resyncFailed),
             (.disabled, .upsertDBFailed),
             (.disabled, .openWebSocketFailed),
             (.disabled, .sendPingFailed),
             (.disabled, .closeWebSocketFailed):
            return (.disabled, .nullEffect)
        }
    }
}
