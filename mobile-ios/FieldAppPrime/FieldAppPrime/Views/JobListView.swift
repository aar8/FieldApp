import SwiftUI

struct JobListView: View {
    @ObservedObject var viewModel: JobListViewModel
    @State private var selectedJob: Job? = nil

    init(viewModel: JobListViewModel) {
        self.viewModel = viewModel
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
                JobDetailView(job: job)
            }
        }
    }
}

struct JobDetailView: View {
    let job: Job

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Job Number: \(job.jobNumber)")
                    .font(.title2)
                Text(job.jobDescription ?? "No description available.")
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
