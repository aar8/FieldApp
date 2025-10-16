import Foundation

/// Represents the data payload for a Job in the domain layer.
struct JobDomainData: Hashable {
    var title: String
    var description: String?
}

/// Represents a single job record in the system.
/// This is a "clean" domain model with no persistence-specific code.
struct Job: Identifiable, Hashable {
    let id: Int
    var tenantId: String
    var objectType: String
    var status: String
    var data: JobDomainData // This now uses the clear domain-specific model
    var version: Int
    var createdAt: Date
    var updatedAt: Date
}
