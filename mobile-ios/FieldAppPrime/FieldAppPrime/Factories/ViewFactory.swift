import Foundation
import SwiftUI
import Insieme

class ViewFactory {
    
    private let databaseService: DatabaseService

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    @ViewBuilder
    func makeJobListView() -> some View {
        let viewModel = JobListViewModel(databaseService: databaseService)
        JobListView(viewModel: viewModel, viewFactory: self)
    }

        @ViewBuilder
    func makeJobDetailView(job: Job) -> some View {
        let viewModel = JobDetailViewModel(job: job, databaseService: databaseService)
        JobDetailView(viewModel: viewModel)
    }
}
