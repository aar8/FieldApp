import Foundation

/// A clean, flattened domain model for Object Metadata, suitable for use in UI and business logic.
struct ObjectMetadata: Identifiable, Hashable {
    let id: String
    let objectName: String
    let fieldDefinitions: [FieldDefinition]
}
