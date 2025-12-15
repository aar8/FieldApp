import Foundation
import Insieme

struct JobDataUpdates: Codable {
    var jobNumber: FieldUpdate<String> = .noUpdate
    var customerId: FieldUpdate<String> = .noUpdate
    var jobAddress: FieldUpdate<Address?> = .noUpdate
    var jobDescription: FieldUpdate<String?> = .noUpdate
    var assignedTechId: FieldUpdate<String?> = .noUpdate
    var statusNote: FieldUpdate<String?> = .noUpdate
    var quoteId: FieldUpdate<String?> = .noUpdate
    var equipmentId: FieldUpdate<String?> = .noUpdate

    enum CodingKeys: String, CodingKey {
        case jobNumber = "job_number"
        case customerId = "customer_id"
        case jobAddress = "job_address"
        case jobDescription = "job_description"
        case assignedTechId = "assigned_tech_id"
        case statusNote = "status_note"
        case quoteId = "quote_id"
        case equipmentId = "equipment_id"
    }
    
    init() { }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if container.contains(.jobNumber) {
            let value = try container.decode(String.self, forKey: .jobNumber)
            self.jobNumber = .updated(value)
        }
        if container.contains(.customerId) {
            let value = try container.decode(String.self, forKey: .customerId)
            self.customerId = .updated(value)
        }
        if container.contains(.jobAddress) {
            let value = try container.decode(Address?.self, forKey: .jobAddress)
            self.jobAddress = .updated(value)
        }
        if container.contains(.jobDescription) {
            let value = try container.decode(String?.self, forKey: .jobDescription)
            self.jobDescription = .updated(value)
        }
        if container.contains(.assignedTechId) {
            let value = try container.decode(String?.self, forKey: .assignedTechId)
            self.assignedTechId = .updated(value)
        }
        if container.contains(.statusNote) {
            let value = try container.decode(String?.self, forKey: .statusNote)
            self.statusNote = .updated(value)
        }
        if container.contains(.quoteId) {
            let value = try container.decode(String?.self, forKey: .quoteId)
            self.quoteId = .updated(value)
        }
        if container.contains(.equipmentId) {
            let value = try container.decode(String?.self, forKey: .equipmentId)
            self.equipmentId = .updated(value)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if case .updated(let value) = jobNumber {
            try container.encode(value, forKey: .jobNumber)
        }
        if case .updated(let value) = customerId {
            try container.encode(value, forKey: .customerId)
        }
        if case .updated(let value) = jobAddress {
            try container.encode(value, forKey: .jobAddress)
        }
        if case .updated(let value) = jobDescription {
            try container.encode(value, forKey: .jobDescription)
        }
        if case .updated(let value) = assignedTechId {
            try container.encode(value, forKey: .assignedTechId)
        }
        if case .updated(let value) = statusNote {
            try container.encode(value, forKey: .statusNote)
        }
        if case .updated(let value) = quoteId {
            try container.encode(value, forKey: .quoteId)
        }
        if case .updated(let value) = equipmentId {
            try container.encode(value, forKey: .equipmentId)
        }
    }

    static func from(overlays: [OverlayRecord]) -> JobDataUpdates {
        let sortedOverlays = overlays.sorted { $0.createdAt < $1.createdAt }
        
        let finalUpdates = sortedOverlays.reduce(into: JobDataUpdates()) { acc, overlay in
            guard let updates = try? JSONDecoder().decode(JobDataUpdates.self, from: overlay.changes) else { return }
            
            acc.jobNumber = acc.jobNumber.merged(with: updates.jobNumber)
            acc.customerId = acc.customerId.merged(with: updates.customerId)
            acc.jobAddress = acc.jobAddress.merged(with: updates.jobAddress)
            acc.jobDescription = acc.jobDescription.merged(with: updates.jobDescription)
            acc.assignedTechId = acc.assignedTechId.merged(with: updates.assignedTechId)
            acc.statusNote = acc.statusNote.merged(with: updates.statusNote)
            acc.quoteId = acc.quoteId.merged(with: updates.quoteId)
            acc.equipmentId = acc.equipmentId.merged(with: updates.equipmentId)
        }
        return finalUpdates
    }
}

extension Job {
    func applying(updates: JobDataUpdates) -> Job {
        var newJobNumber = self.jobNumber
        var newCustomerId = self.customerId
        var newJobAddress = self.jobAddress
        var newJobDescription = self.jobDescription
        var newAssignedTechId = self.assignedTechId
        var newStatusNote = self.statusNote
        var newQuoteId = self.quoteId
        var newEquipmentId = self.equipmentId

        if case .updated(let value) = updates.jobNumber {
            newJobNumber = value
        }
        if case .updated(let value) = updates.customerId {
            newCustomerId = value
        }
        if case .updated(let value) = updates.jobAddress {
            newJobAddress = value
        }
        if case .updated(let value) = updates.jobDescription {
            newJobDescription = value
        }
        if case .updated(let value) = updates.assignedTechId {
            newAssignedTechId = value
        }
        if case .updated(let value) = updates.statusNote {
            newStatusNote = value
        }
        if case .updated(let value) = updates.quoteId {
            newQuoteId = value
        }
        if case .updated(let value) = updates.equipmentId {
            newEquipmentId = value
        }

        return Job(
            id: self.id,
            objectName: self.objectName,
            objectType: self.objectType,
            status: self.status,
            jobNumber: newJobNumber,
            customerId: newCustomerId,
            jobAddress: newJobAddress,
            jobDescription: newJobDescription,
            assignedTechId: newAssignedTechId,
            statusNote: newStatusNote,
            quoteId: newQuoteId,
            equipmentId: newEquipmentId
        )
    }
}
