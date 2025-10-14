import Foundation
import SwiftUI

/// A factory responsible for creating and composing views and their corresponding view models.
class ViewFactory {
    
    // MARK: - Services
    private let databaseService: DatabaseService
    // In the future, other services like APIService would be added here.

    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }

    // MARK: - View Builders

    @ViewBuilder
    func makeJobListView() -> some View {
        // The factory creates the ViewModel...
        let viewModel = JobListViewModel(databaseService: databaseService)
        // ...and injects it into the View.
        JobListView(viewModel: viewModel)
    }
}
