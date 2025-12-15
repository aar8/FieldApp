import Foundation
import Combine
import ReactiveSwift
import GRDB
import Insieme

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
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }
}
