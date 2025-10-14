/// `SyncCoordinator` manages the complex process of synchronizing local data with a remote server.
///
/// ## Architecture
///
/// This component is implemented as a **Finite State Machine (FSM)** that transitions between various `SyncState`s
/// (e.g., `resync`, `webSocketConnected`, `disabled`).
///
/// It uses a "Functional Core, Imperative Shell" pattern to isolate decision-making from side-effects:
///
/// - **Functional Core (`SyncCoordinator`)**: The coordinator itself is the "brain". The `send(event:)` method acts as a
///   pure "reducer" function. It takes the current state and an incoming `SyncEvent`, and deterministically calculates
///   the next state and the next `SyncEffect` to run. It does not perform any networking or database calls itself.
///
/// - **Imperative Shell (`SyncEffectHandler`)**: An external object conforming to the `SyncEffectHandler`
///   protocol is the "muscle". It is responsible for executing the `SyncEffect`s (like making network calls,
///   sleeping, or accessing the database) and reporting the result back to the coordinator via an event.
///
/// ## Flow
///
/// 1. An event (`SyncEvent`) is sent to the `send(event:)` method.
/// 2. The reducer calculates a new state and a new effect.
/// 3. The coordinator's state is updated.
/// 4. The new effect is passed to the `SyncEffectHandler` to be executed.
/// 5. The `SyncEffectHandler` completes the effect and posts its result back as a `SyncEvent`, repeating the cycle.
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

protocol SyncEffectHandler {
    func runEffect(syncEffect: SyncEffect)
    
    func effectCompleted(callback: (Result<SyncEffectResult, SyncEffectError>)->())
}

//  Transitions:
//
//   disconnected --> resync(syncInterval + 5)
//   resync -> (
//       initializeWebSocket.        // Side effect syncInterval = 0      || 
//       disconnected(syncFailed)    // Side effect syncInterval += 5
//   )
//   initializeWebSocket --> (webSocketConnected | disconnected(webSocketConnectFailed))
//   webSocketConnected -> disconnected(missedPing)
enum DisconectedReason {
    case missedPing
    case initializing
    case webSocketConnectFailed
    case syncFailed
}

enum SyncState {
    case disconnected(DisconectedReason)        
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
//        var syncState: SyncState = .disconnected(.initializing)
        self.effectHandler = effectHandler
        effectHandler.effectCompleted { result in
            /*let (newState, newEffect) = */send(event: .effectResult(result))
            
//            currentState = newState
//            effectHandler.runEffect(syncEffect: newEffect)
        }
    }

    func foreground() {
        send(event: .foreground)

//        effectHandler.runEffect(updateState(.resync(0)));
    }

    func background() {
        send(event: .background)
    }

    func send(event: SyncEvent) {
        let syncState = self.currentState
        let (newState, newEffect) =
        switch (event) {
        case .effectResult(let result):
            effectCompleted(syncState, result)
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

    func effectSuccessful(_ syncState: SyncState, _ success: SyncEffectResult) -> (SyncState, SyncEffect) {
        // let success: SyncEffectResult = ...
        switch (syncState, success) {
            // Web socket closed due to instability
            case (.resync(let t), .closeWebSocketSuccessful):
                return (syncState, .sleep(t));

            case (.resync, .sleepSuccessful):
                return (syncState, .readLastModified);

            case (.resync, .readLastModifiedSuccessful(let lm)):
                return (syncState, .resync(lm));

            case (.resync, .resyncSuccessful):
                return (.initializeWebSocket, .openWebSocket);

            case (.initializeWebSocket, .openWebSocketSuccessful):
                return (.webSocketConnected, .sendPing);

            case (.webSocketConnected, .sendPingSuccessful):
                return (.webSocketConnected, .sleep(30))

            case (.webSocketConnected, .sleepSuccessful):
                return (.webSocketConnected, .sendPing)
            default:
                return (.disabled, .nullEffect);
//        case (.disconnected(_), _):
//            <#code#>
//        case (.disabled, _):
//            <#code#>
//        case (.webSocketConnected, .readLastModifiedSuccessful(_)):
//            <#code#>
//        case (.webSocketConnected, .resyncSuccessful(_)):
//            <#code#>
//        case (.webSocketConnected, .openWebSocketSuccessful):
//            <#code#>
//        case (.webSocketConnected, .closeWebSocketSuccessful):
//            <#code#>
//        case (.initializeWebSocket, .sleepSuccessful):
//            <#code#>
//        case (.initializeWebSocket, .readLastModifiedSuccessful(_)):
//            <#code#>
//        case (.initializeWebSocket, .resyncSuccessful(_)):
//            <#code#>
//        case (.initializeWebSocket, .sendPingSuccessful):
//            <#code#>
//        case (.initializeWebSocket, .closeWebSocketSuccessful):
//            <#code#>
//        case (.resync(_), .openWebSocketSuccessful):
//            <#code#>
//        case (.resync(_), .sendPingSuccessful):
//            <#code#>
        }
    }
    
//     enum SyncEffectError {
//     .readLastModifiedFailed
//     .resyncFailed
//     .sendPingFailed
//     .openWebSocketFailed
//     .closeWebSocketFailed
// }

    func effectFailed(_ syncState: SyncState, _ error: SyncEffectError) -> (SyncState, SyncEffect) {
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
            
        default:
            return (.disabled, .nullEffect)

        }
    }

    func effectCompleted(_ syncState: SyncState, _ result: Result<SyncEffectResult, SyncEffectError>) ->  (SyncState, SyncEffect) {
        switch result {
        case .success(let value):
            effectSuccessful(syncState, value)
        case .failure(let error):
            effectFailed(syncState, error)
        }
    }

    // state affected by external input
//    func updateState(_ currentState, _ newState: SyncState) -> SyncEffect {
//        switch (currentState, newState) {
//            case (_, .resync(wait)):
//            self.currentState = .resync(wait:wait)
//                return .sleep(wait)
//                // return .readLastModified;
//        }
//    }
}
