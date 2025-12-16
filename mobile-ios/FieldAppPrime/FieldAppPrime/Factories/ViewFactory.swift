import Foundation
import SwiftUI
import Insieme
import SyncClient

class ViewFactory {
    
    private let modelDataService: ModelDataService
    private let databaseService: SyncClientDatabase

    init(modelDataService: ModelDataService, databaseService: SyncClientDatabase) {
        self.modelDataService = modelDataService
        self.databaseService = databaseService
    }

    @ViewBuilder
    func makeJobListView() -> some View {
        let viewModel = JobListViewModel(modelDataService: modelDataService)
        JobListView(viewModel: viewModel, viewFactory: self)
    }

    @ViewBuilder
    func makeJobDetailView(job: Job) -> some View {
        let viewModel = JobDetailViewModel(job: job, databaseService: databaseService)
        JobDetailView(viewModel: viewModel)
    }
}
