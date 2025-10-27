import Foundation

/// Represents a single job, flattened for easy use in UI and business logic.
/// This is a "clean" domain model, independent of persistence or network layers.
struct Job: Identifiable, Hashable {
    let id: String
    let status: String
    let version: Int
    let updatedAt: String
    
    // Properties from the 'data' blob
    let jobNumber: String
    let customerId: String
    let jobAddress: String?
    let jobDescription: String?
    let assignedTechId: String?
    let statusNote: String?
}

