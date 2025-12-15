import Vapor
import Insieme

// This extension makes the shared SyncResponse model conform to Vapor's Content protocol.
extension SyncResponse: Content {}
