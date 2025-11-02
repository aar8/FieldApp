import Foundation
import Combine
import ReactiveSwift
import GRDB

class JobDetailViewModel: ObservableObject {

    let (viewDidAppear, viewDidAppearObserver) = Signal<(), Never>.pipe()

    init(job: Job, databaseService: DatabaseService) {
        let metadataService = DefaultMetadataService(databaseService: databaseService)

        let objectMetadata = metadataService.getObjectMetadata(for: "job")?.model
        let layout = metadataService.getLayoutDefinition(for: "job", type: job.objectType, status: job.status)?.model

        print(objectMetadata)
        print(layout)
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }
}
