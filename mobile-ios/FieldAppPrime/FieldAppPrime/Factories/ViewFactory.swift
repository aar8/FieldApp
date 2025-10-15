import Foundation
import SwiftUI

class ViewFactory {
    
    private let databaseService: DatabaseService

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }


    @ViewBuilder
    func makeJobListView() -> some View {
        let viewModel = JobListViewModel(databaseService: databaseService)
        JobListView(viewModel: viewModel)
    }
}
