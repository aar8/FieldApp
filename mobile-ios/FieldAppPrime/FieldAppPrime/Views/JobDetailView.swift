import SwiftUI

struct JobDetailView: View {
    @ObservedObject var viewModel: JobDetailViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isEditing = false
    @State private var edits: [String: String] = [:]

    init(viewModel: JobDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Form {
                ForEach(viewModel.layoutFields, id: \.key) { field in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(field.label)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if isEditing {
                            TextField(field.label, text: Binding(
                                get: { edits[field.key] ?? field.value ?? "" },
                                set: { edits[field.key] = $0 }
                            ))
                            .font(.body)
                        } else {
                            Text(field.value ?? "—")
                                .font(.body)
                        }
                    }
                    .padding(.vertical, 3)
                }
            }
            .navigationTitle("Job Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEditing ? "Cancel" : "Close") {
                        if isEditing {
                            isEditing = false
                            edits = [:] // Discard changes
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            // TODO: viewModel.save(edits: edits)
//                            print("Saving edits: \(edits)")
//                            edits = [:]
                            viewModel.saveChanges(edits)
                        }
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}
//
//let layoutFields: [(name: String, def: FieldDefinition, value: String?)]
//      @State private var edits: [String: String] = [:]
//
//      var body: some View {
//          VStack(alignment: .leading, spacing: 12) {
//              ForEach(layoutFields, id: \.name) { field in
//                  VStack(alignment: .leading, spacing: 4) {
//                      Text(field.def.label ?? field.name)
//                          .font(.headline)
//
//                      TextField(
//                          field.def.label ?? field.name,
//                          text: binding(for: field)
//                      )
//                      .textFieldStyle(.roundedBorder)
//                  }
//              }
//          }
//          .padding()
//      }
//
//      private func binding(for field: (name: String, def: FieldDefinition, value: String?)) -> Binding<String> {
//          Binding(
//              get: { edits[field.name] ?? field.value ?? "" },
//              set: { edits[field.name] = $0 }
//          )
//      }
