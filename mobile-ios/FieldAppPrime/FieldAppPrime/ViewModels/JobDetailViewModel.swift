import Foundation
import Combine
import ReactiveSwift
import GRDB

class JobDetailViewModel: ObservableObject {

    let (viewDidAppear, viewDidAppearObserver) = Signal<(), Never>.pipe()
    let layoutFields: [(key: String, label: String, value: String?)]

    init(job: Job, databaseService: DatabaseService) {
        let metadataService = DefaultMetadataService(databaseService: databaseService)

        guard let objectMetadata = metadataService.getObjectMetadata(for: "job")?.model else {
            self.layoutFields = []
            return
        }
        guard let layout = metadataService.getLayoutDefinition(for: "job", type: job.objectType, status: job.status)?.model  else {
            self.layoutFields = []
            return
        }

        let fieldDefsByFieldName = objectMetadata.fieldDefinitions
             .reduce(into: [String: FieldDefinition]()) { result, definition in
                 result[definition.name] = definition
             }
        
        let fieldNames: [String] = layout.sections.first?.fields ?? []
        
        self.layoutFields = fieldNames.compactMap { fieldName in
            guard let fieldDef = fieldDefsByFieldName[fieldName] else { return nil }
            let fieldValue: String? = job.value(for: fieldName) as? String ?? String?.none
            
            return (fieldName, fieldDef.label, fieldValue)
        }
        
        print(layoutFields)
        print(objectMetadata)
        print(layout)
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }
}
