import Foundation

// MARK: - Main Response Structure

struct SyncResponse: Decodable {
    let meta: Meta
    let data: DataPayload
}

// MARK: - Meta

struct Meta: Decodable {
    let serverTime: Date
    let since: String

    enum CodingKeys: String, CodingKey {
        case serverTime = "server_time"
        case since
    }
}

// MARK: - Generic API Record Wrapper

struct APIRecord<T: Codable>: Codable {
    let id: String
    let tenantId: String
    let objectName: String
    let objectType: String
    let status: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let data: T

    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Data Payload

struct DataPayload: Decodable {
    let users: [APIRecord<UserData>]
    let customers: [APIRecord<CustomerData>]
    let jobs: [APIRecord<JobData>]
    let calendarEvents: [APIRecord<CalendarEventData>]
    let pricebooks: [APIRecord<PricebookData>]
    let products: [APIRecord<ProductData>]
    let locations: [APIRecord<LocationData>]
    let productItems: [APIRecord<ProductItemData>]
    let pricebookEntries: [APIRecord<PricebookEntryData>]
    let jobLineItems: [APIRecord<JobLineItemData>]
    let quotes: [APIRecord<QuoteData>]
    let objectFeeds: [APIRecord<ObjectFeedData>]
    let invoices: [APIRecord<InvoiceData>]
    let invoiceLineItems: [APIRecord<InvoiceLineItemData>]
    let objectMetadata: [APIObjectMetadataRecord]
    let layoutDefinitions: [APILayoutDefinitionRecord]
    
    enum CodingKeys: String, CodingKey {
        case users, customers, jobs, pricebooks, products, locations, quotes, invoices
        case calendarEvents = "calendar_events"
        case productItems = "product_items"
        case pricebookEntries = "pricebook_entries"
        case jobLineItems = "job_line_items"
        case objectFeeds = "object_feeds"
        case invoiceLineItems = "invoice_line_items"
        case objectMetadata = "object_metadata"
        case layoutDefinitions = "layout_definitions"
    }
}

// MARK: - Concrete Data Models (Matching schema.md)

struct JobData: Codable, Hashable {
    let jobNumber: String
    let customerId: String
    let jobAddress: String?
    let jobDescription: String?
    let assignedTechId: String?
    let statusNote: String?
    let quoteId: String?
    let equipmentId: String?
    
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
}

struct UserData: Codable, Hashable {
    let email: String
    let displayName: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case displayName = "display_name"
        case role
    }
}

struct CustomerData: Codable, Hashable {
    let name: String
    let contact: ContactInfo?
    let address: Address?
}

struct ContactInfo: Codable, Hashable {
    let email: String?
    let phone: String?
}

struct Address: Codable, Hashable {
    let street: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    
    enum CodingKeys: String, CodingKey {
        case street, city, state, country
        case zipCode = "zip_code"
    }
}

struct CalendarEventData: Codable, Hashable {
    let title: String
    let startTime: String
    let endTime: String
    let isAllDay: Bool?
    let jobId: String?
    let userId: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case startTime = "start_time"
        case endTime = "end_time"
        case isAllDay = "is_all_day"
        case jobId = "job_id"
        case userId = "user_id"
    }
}

struct PricebookData: Codable, Hashable {
    let name: String
    let description: String?
    let isActive: Bool
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, currency
        case isActive = "is_active"
    }
}

struct ProductData: Codable, Hashable {
    let name: String
    let description: String?
    let productCode: String?
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case name, description, type
        case productCode = "product_code"
    }
}

struct LocationData: Codable, Hashable {
    let name: String
    let address: Address?
}

struct ProductItemData: Codable, Hashable {
    let quantityOnHand: Double
    let productId: String
    let locationId: String
    
    enum CodingKeys: String, CodingKey {
        case quantityOnHand = "quantity_on_hand"
        case productId = "product_id"
        case locationId = "location_id"
    }
}

struct PricebookEntryData: Codable, Hashable {
    let price: Double
    let currency: String
    let pricebookId: String
    let productId: String
    
    enum CodingKeys: String, CodingKey {
        case price, currency
        case pricebookId = "pricebook_id"
        case productId = "product_id"
    }
}

struct JobLineItemData: Codable, Hashable {
    let quantity: Double
    let priceAtTimeOfSale: Double
    let description: String?
    let jobId: String
    let productId: String
    
    enum CodingKeys: String, CodingKey {
        case quantity, description
        case priceAtTimeOfSale = "price_at_time_of_sale"
        case jobId = "job_id"
        case productId = "product_id"
    }
}

struct QuoteData: Codable, Hashable {
    let quoteNumber: String
    let customerId: String
    let pricebookId: String?
    let totalAmount: Double
    let currency: String
    let quoteStatus: String
    let notes: String?
    let preparedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case currency, notes
        case quoteNumber = "quote_number"
        case customerId = "customer_id"
        case pricebookId = "pricebook_id"
        case totalAmount = "total_amount"
        case quoteStatus = "quote_status"
        case preparedBy = "prepared_by"
    }
}

struct ObjectFeedData: Codable, Hashable {
    let relatedObjectName: String
    let relatedRecordId: String
    let entryType: String
    let message: String?
    let authorId: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case relatedObjectName = "related_object_name"
        case relatedRecordId = "related_record_id"
        case entryType = "entry_type"
        case authorId = "author_id"
    }
}

struct InvoiceData: Codable, Hashable {
    let invoiceNumber: String
    let customerId: String
    let jobId: String?
    let quoteId: String?
    let subtotalAmount: Double
    let taxAmount: Double?
    let discountAmount: Double?
    let totalAmount: Double
    let currency: String
    let issueDate: String
    let dueDate: String?
    let paymentStatus: String
    let notes: String?
    let issuedBy: String?
    
    enum CodingKeys: String, CodingKey {
        case currency, notes
        case invoiceNumber = "invoice_number"
        case customerId = "customer_id"
        case jobId = "job_id"
        case quoteId = "quote_id"
        case subtotalAmount = "subtotal_amount"
        case taxAmount = "tax_amount"
        case discountAmount = "discount_amount"
        case totalAmount = "total_amount"
        case issueDate = "issue_date"
        case dueDate = "due_date"
        case paymentStatus = "payment_status"
        case issuedBy = "issued_by"
    }
}

struct InvoiceLineItemData: Codable, Hashable {
    let quantity: Double
    let priceAtTimeOfInvoice: Double
    let description: String?
    let invoiceId: String
    let productId: String
    let taxRate: Double?
    let discountAmount: Double?
    
    enum CodingKeys: String, CodingKey {
        case quantity, description
        case priceAtTimeOfInvoice = "price_at_time_of_invoice"
        case invoiceId = "invoice_id"
        case productId = "product_id"
        case taxRate = "tax_rate"
        case discountAmount = "discount_amount"
    }
}

// MARK: - Metadata Records

struct APIObjectMetadataRecord: Codable {
    let id: String
    let tenantId: String
    let objectName: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let data: ObjectMetadataData

    enum CodingKeys: String, CodingKey {
        case id, data, version
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ObjectMetadataData: Codable, Hashable {
    let fieldDefinitions: [FieldDefinition]
    
    enum CodingKeys: String, CodingKey {
        case fieldDefinitions = "field_definitions"
    }
}

enum FieldType: String, Codable, Hashable {
    case string, date, picklist, checkbox, bool, numeric, currency, reference, file
}

enum FieldFormat: String, Codable, Hashable {
    case email, phone, url
}

struct FieldDefinition: Codable, Hashable {
    let name: String
    let label: String
    let type: FieldType
    let required: Bool?
    let format: FieldFormat?
    let options: [String]?
    let targetObject: String?
    
    enum CodingKeys: String, CodingKey {
        case name, label, type, required, format, options
        case targetObject = "target_object"
    }
}

struct APILayoutDefinitionRecord: Codable {
    let id: String
    let tenantId: String
    let objectName: String
    let objectType: String
    let status: String
    let version: Int
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let data: LayoutDefinitionData

    enum CodingKeys: String, CodingKey {
        case id, data, version, status
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct LayoutDefinitionData: Codable, Hashable {
    let sections: [LayoutSection]
}

struct LayoutSection: Codable, Hashable {
    let label: String
    let fields: [String]
}


// MARK: - API to Record Mappings

extension APIRecord where T == JobData {
    var asJobRecord: JobRecord {
        JobRecord(
            id: self.id,
            tenantId: self.tenantId,
            objectName: self.objectName,
            objectType: self.objectType,
            status: self.status,
            version: self.version,
            createdBy: self.createdBy,
            modifiedBy: self.modifiedBy,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            data: self.data
        )
    }
}

extension APIObjectMetadataRecord {
    var asObjectMetadataRecord: ObjectMetadataRecord {
        ObjectMetadataRecord(
            id: self.id,
            tenantId: self.tenantId,
            objectName: self.objectName,
            version: self.version,
            createdBy: self.createdBy,
            modifiedBy: self.modifiedBy,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            data: self.data
        )
    }
}

extension APILayoutDefinitionRecord {
    var asLayoutDefinitionRecord: LayoutDefinitionRecord {
        LayoutDefinitionRecord(
            id: self.id,
            tenantId: self.tenantId,
            objectName: self.objectName,
            objectType: self.objectType,
            status: self.status,
            version: self.version,
            createdBy: self.createdBy,
            modifiedBy: self.modifiedBy,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt,
            data: self.data
        )
    }
}

