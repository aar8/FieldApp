import Foundation
import Combine
import ReactiveSwift
import GRDB

enum AppError: Error {
    
}

class JobListViewModel: ObservableObject {
    
    // MARK: - Public Properties
    let jobs: Property<[Job]>
    let errorMessage: Property<String?> = .init(value: nil)
    let isLoading: Property<Bool> = .init(value: false)

    let (viewDidAppear, viewDidAppearObserver) = Signal<(), Never>.pipe()

    init(databaseService: DatabaseService) {
        self.jobs = databaseService.jobs
        
        databaseService.jobs.signal.combineLatest(with: self.viewDidAppear)
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.objectWillChange.send()
            }

//        // 3. The `errorMessage` property is defined by the errors of the fetch action.
//        self.errorMessage = Property(initial: nil, then: fetchAction.errors.map { "Error: \($0.localizedDescription)" })
//        
//        // 4. The `isLoading` property is true whenever the action is executing.
//        self.isLoading = fetchAction.isExecuting
//
//        // 5. Bridge to SwiftUI's update mechanism.
//        //    Any time any of our properties change, we notify the view.
//        Property.combineLatest(jobs, errorMessage, isLoading).signal
//            .observe(on: UIScheduler())
//            .observeValues { [weak self] _, _, _ in
//                self?.objectWillChange.send()
//            }
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }
}
