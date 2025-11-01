import SwiftUI

struct JobDetailView: View {
    @ObservedObject var viewModel: JobDetailViewModel

    init(viewModel: JobDetailViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Job Number: x")
                    .font(.title2)
                Text("job.jobDescription" ?? "No description available.")
                    .font(.body)
                Spacer()
            }
            .padding()
            .navigationTitle("Job Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // SwiftUI automatically dismisses sheet
                    }
                }
            }
        }
    }
}
