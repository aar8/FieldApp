import Foundation

/// A clean, flattened domain model for a Layout Definition.
struct LayoutDefinition: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let sections: [LayoutSection]
}
