

import Foundation
import ReactiveSwift

protocol WebSocketService {
    /// A producer that emits a value when the local data is stale
    /// and needs to be synced with the server.
    var isStale: SignalProducer<Void, Never> { get }
    
    /// Connects to the WebSocket server.
    func connect()
    
    /// Disconnects from the WebSocket server.
    func disconnect()
}

class DefaultWebSocketService: WebSocketService {
    let isStale: SignalProducer<Void, Never>
    private let isStaleObserver: Signal<Void, Never>.Observer
    
    // In a real implementation, this would be a URLSessionWebSocketTask.
    private var webSocketTask: URLSessionWebSocketTask?

    init() {
        let (isStaleSignal, isStaleObserver) = Signal<Void, Never>.pipe()
        self.isStale = SignalProducer(isStaleSignal)
        self.isStaleObserver = isStaleObserver
    }
    
    func connect() {
        // In a real implementation, you would create and configure
        // a URLSessionWebSocketTask here.
        
        // For example:
        // let url = URL(string: "wss://your-server.com/socket")!
        // let request = URLRequest(url: url)
        // self.webSocketTask = URLSession.shared.webSocketTask(with: request)
        // self.webSocketTask?.resume()
        // self.listenForMessages()
        
        print("WebSocketService: Connecting (mock)...")
        
        // To simulate receiving a stale message after 5 seconds:
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            print("WebSocketService: Received stale message (mock).")
            self.isStaleObserver.send(value: ())
        }
    }
    
    func disconnect() {
        print("WebSocketService: Disconnecting...")
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func listenForMessages() {
        self.webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                // Handle incoming messages.
                // If a message indicates data is stale, call:
                // self?.isStaleObserver.send(value: ())
                
                // Example of handling a string message:
                if case .string(let text) = message {
                    print("Received message: \(text)")
                    if text == "data_stale" {
                        self?.isStaleObserver.send(value: ())
                    }
                }
                
                // Continue listening for more messages.
                self?.listenForMessages()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
}
