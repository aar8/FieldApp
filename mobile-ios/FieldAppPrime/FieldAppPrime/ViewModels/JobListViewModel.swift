import Foundation
import Combine
import ReactiveSwift
import GRDB

class JobListViewModel: ObservableObject {
    
    // MARK: - Public Properties
    let jobs: Property<[Job]>
    let errorMessage: Property<String?>
    let isLoading: Property<Bool>

    // MARK: - Private Properties
    private let fetchAction: Action<Void, [Job], AppError>

    init(databaseService: DatabaseService) {
        // 1. Define the action that fetches jobs from the database.
        self.fetchAction = Action {
            databaseService.fetch(JobDTO.all())
        }

        // 2. The `jobs` property is now defined by the output of the fetch action.
        //    It starts empty and is replaced by the action's results.
        self.jobs = Property(initial: [], then: fetchAction.values)

        // 3. The `errorMessage` property is defined by the errors of the fetch action.
        self.errorMessage = Property(initial: nil, then: fetchAction.errors.map { "Error: \($0.localizedDescription)" })
        
        // 4. The `isLoading` property is true whenever the action is executing.
        self.isLoading = fetchAction.isExecuting

        // 5. Bridge to SwiftUI's update mechanism.
        //    Any time any of our properties change, we notify the view.
        Property.combineLatest(jobs, errorMessage, isLoading).signal
            .observe(on: UIScheduler())
            .observeValues { [weak self] _, _, _ in
                self?.objectWillChange.send()
            }
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.fetchAction.apply().start()
    }
}
