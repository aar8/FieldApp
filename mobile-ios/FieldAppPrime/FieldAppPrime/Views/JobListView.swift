import SwiftUI

struct JobListView: View {
    let viewFactory: ViewFactory
    @ObservedObject var viewModel: JobListViewModel
    @State private var selectedJob: Job? = nil

    init(viewModel: JobListViewModel, viewFactory: ViewFactory) {
        self.viewModel = viewModel
        self.viewFactory = viewFactory
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Read the current value from the ReactiveSwift Property
                List(viewModel.jobs.value) { job in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.jobNumber)
                            .font(.headline)
                        Text(job.jobDescription ?? "No description")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle()) // makes the whole row tappable
                    .onTapGesture {
                        selectedJob = job
                    }
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
            .sheet(item: $selectedJob) { job in
                viewFactory.makeJobDetailView(job: job)
            }
        }
    }
}
