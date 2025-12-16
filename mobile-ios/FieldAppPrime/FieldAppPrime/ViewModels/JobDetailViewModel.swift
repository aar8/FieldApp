import Foundation
import Combine
import ReactiveSwift
import GRDB
import Insieme
import SyncClient

class JobDetailViewModel: ObservableObject {

    let (viewDidAppear, viewDidAppearObserver) = Signal<(), Never>.pipe()
    let layoutFields: [(key: String, label: String, value: String?)]
    var jobChanges = JobDataUpdates();
    let job: Job
    private let databaseService: SyncClientDatabase
    
    init(job: Job, databaseService: SyncClientDatabase) {
        self.job = job
        self.databaseService = databaseService
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
        let fields: [Job.Field] = fieldNames.compactMap(Job.Field.from(name:))
        
        self.layoutFields = fields.compactMap { field in
            guard let fieldDef = fieldDefsByFieldName[field.key] else { return nil }
            let fieldValue: String? = job.value(for: field) as? String ?? String?.none
            
            return (field.key, fieldDef.label, fieldValue)
        }
        
        print(layoutFields)
        print(objectMetadata)
        print(layout)
    }
    
    // The view will call this method when it appears.
    func onAppear() {
        self.viewDidAppearObserver.send(value: ())
    }

    private func getUpdate<T: Equatable>(currentValue: T, originalValue: T) -> FieldUpdate<T> {
        if currentValue == originalValue {
            return .noUpdate
        } else {
            return .updated(currentValue)
        }
    }

    func saveChanges(_ changes: [String: String]) {
        self.jobChanges = changes.reduce(into: self.jobChanges) { newUpdates, kvp in
            guard let field = Job.Field.from(name: kvp.key) else { return }
            
            switch field {
            case .id, .objectName, .objectType, .status:
                break
            case .jobNumber:
                newUpdates.jobNumber = getUpdate(currentValue: kvp.value, originalValue: job.jobNumber)
            case .customerId:
                newUpdates.customerId = getUpdate(currentValue: kvp.value, originalValue: job.customerId)
            case .jobAddress:
                // FIXME: Address is a complex type. Cannot update from a simple String.
                break
            case .jobDescription:
                let updatedValue = kvp.value.isEmpty ? nil : kvp.value
                newUpdates.jobDescription = getUpdate(currentValue: updatedValue, originalValue: job.jobDescription)
            case .assignedTechId:
                let updatedValue = kvp.value.isEmpty ? nil : kvp.value
                newUpdates.assignedTechId = getUpdate(currentValue: updatedValue, originalValue: job.assignedTechId)
            case .statusNote:
                let updatedValue = kvp.value.isEmpty ? nil : kvp.value
                newUpdates.statusNote = getUpdate(currentValue: updatedValue, originalValue: job.statusNote)
            case .quoteId:
                let updatedValue = kvp.value.isEmpty ? nil : kvp.value
                newUpdates.quoteId = getUpdate(currentValue: updatedValue, originalValue: job.quoteId)
            case .equipmentId:
                let updatedValue = kvp.value.isEmpty ? nil : kvp.value
                newUpdates.equipmentId = getUpdate(currentValue: updatedValue, originalValue: job.equipmentId)
            }
        }

        let result = databaseService.saveJobChanges(self.jobChanges, for: self.job)

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(self.jobChanges),
           let jsonString = String(data: data, encoding: .utf8) {
            print("changes json: \(jsonString)")
            if case .failure(let error) = result {
                // Handle error
                print("Error saving job changes: \(error)")
            }
        }
    }
}
