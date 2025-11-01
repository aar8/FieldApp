import Foundation
import Combine
import ReactiveSwift
import GRDB

class JobDetailViewModel: ObservableObject {

    let (viewDidAppear, viewDidAppearObserver) = Signal<(), Never>.pipe()

    init(job: Job, databaseService: DatabaseService) {
       
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }
}
