import SwiftUI

struct JobListView: View {
    @ObservedObject var viewModel: JobListViewModel

    init(viewModel: JobListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Read the current value from the ReactiveSwift Property
                List(viewModel.jobs.value) { job in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.title)
                            .font(.headline)
                        Text(job.status)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                if viewModel.isLoading.value {
                    ProgressView()
                }
                
                if let errorMessage = viewModel.errorMessage.value {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.8))
                }
            }
            .navigationTitle("Jobs")
            .onAppear {
                // Execute the fetch action when the view appears.
                viewModel.onAppear()
            }
        }
    }
}

struct JobListView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a factory with a mock service to build the view for the preview.
        let factory = ViewFactory(databaseService: MockDatabaseService())
        factory.makeJobListView()
    }
}
