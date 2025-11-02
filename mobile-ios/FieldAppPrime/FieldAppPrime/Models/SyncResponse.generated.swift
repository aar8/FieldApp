// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import Foundation
import GRDB


struct JobData: Codable, Hashable {
    let jobNumber: String
    let customerId: String
    let jobAddress: Address?
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

struct JobRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: JobData
    static let databaseTableName = "jobs"
    var model: Job {
        Job(id: id, objectName: objectName, objectType: objectType, status: status, jobNumber: data.jobNumber, customerId: data.customerId, jobAddress: data.jobAddress, jobDescription: data.jobDescription, assignedTechId: data.assignedTechId, statusNote: data.statusNote, quoteId: data.quoteId, equipmentId: data.equipmentId)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct UserData: Codable, Hashable {
    let email: String
    let displayName: String
    let role: String
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case email
        case role
    }
}

struct UserRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: UserData
    static let databaseTableName = "users"
    var model: User {
        User(id: id, objectName: objectName, objectType: objectType, status: status, email: data.email, displayName: data.displayName, role: data.role)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct ContactInfo: Codable, Hashable {
    let email: String?
    let phone: String?
    enum CodingKeys: String, CodingKey {
        case email
        case phone
    }
}

struct Address: Codable, Hashable {
    let street: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    enum CodingKeys: String, CodingKey {
        case zipCode = "zip_code"
        case street
        case city
        case state
        case country
    }
}

struct CustomerData: Codable, Hashable {
    let name: String
    let contact: ContactInfo?
    let address: Address?
    enum CodingKeys: String, CodingKey {
        case name
        case contact
        case address
    }
}

struct CustomerRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: CustomerData
    static let databaseTableName = "customers"
    var model: Customer {
        Customer(id: id, objectName: objectName, objectType: objectType, status: status, name: data.name, contact: data.contact, address: data.address)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
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
        case startTime = "start_time"
        case endTime = "end_time"
        case isAllDay = "is_all_day"
        case jobId = "job_id"
        case userId = "user_id"
        case title
    }
}

struct CalendarEventRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: CalendarEventData
    static let databaseTableName = "calendar_events"
    var model: CalendarEvent {
        CalendarEvent(id: id, objectName: objectName, objectType: objectType, status: status, title: data.title, startTime: data.startTime, endTime: data.endTime, isAllDay: data.isAllDay, jobId: data.jobId, userId: data.userId)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct PricebookData: Codable, Hashable {
    let name: String
    let description: String?
    let isActive: Bool
    let currency: String
    enum CodingKeys: String, CodingKey {
        case isActive = "is_active"
        case name
        case description
        case currency
    }
}

struct PricebookRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: PricebookData
    static let databaseTableName = "pricebooks"
    var model: Pricebook {
        Pricebook(id: id, objectName: objectName, objectType: objectType, status: status, name: data.name, description: data.description, isActive: data.isActive, currency: data.currency)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct ProductData: Codable, Hashable {
    let name: String
    let description: String?
    let productCode: String?
    let type: String
    enum CodingKeys: String, CodingKey {
        case productCode = "product_code"
        case name
        case description
        case type
    }
}

struct ProductRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: ProductData
    static let databaseTableName = "products"
    var model: Product {
        Product(id: id, objectName: objectName, objectType: objectType, status: status, name: data.name, description: data.description, productCode: data.productCode, type: data.type)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct LocationData: Codable, Hashable {
    let name: String
    let address: Address?
    enum CodingKeys: String, CodingKey {
        case name
        case address
    }
}

struct LocationRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: LocationData
    static let databaseTableName = "locations"
    var model: Location {
        Location(id: id, objectName: objectName, objectType: objectType, status: status, name: data.name, address: data.address)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
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

struct ProductItemRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: ProductItemData
    static let databaseTableName = "product_items"
    var model: ProductItem {
        ProductItem(id: id, objectName: objectName, objectType: objectType, status: status, quantityOnHand: data.quantityOnHand, productId: data.productId, locationId: data.locationId)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct PricebookEntryData: Codable, Hashable {
    let price: Double
    let currency: String
    let pricebookId: String
    let productId: String
    enum CodingKeys: String, CodingKey {
        case pricebookId = "pricebook_id"
        case productId = "product_id"
        case price
        case currency
    }
}

struct PricebookEntryRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: PricebookEntryData
    static let databaseTableName = "pricebook_entries"
    var model: PricebookEntry {
        PricebookEntry(id: id, objectName: objectName, objectType: objectType, status: status, price: data.price, currency: data.currency, pricebookId: data.pricebookId, productId: data.productId)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct JobLineItemData: Codable, Hashable {
    let quantity: Double
    let priceAtTimeOfSale: Double
    let description: String?
    let jobId: String
    let productId: String
    enum CodingKeys: String, CodingKey {
        case priceAtTimeOfSale = "price_at_time_of_sale"
        case jobId = "job_id"
        case productId = "product_id"
        case quantity
        case description
    }
}

struct JobLineItemRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: JobLineItemData
    static let databaseTableName = "job_line_items"
    var model: JobLineItem {
        JobLineItem(id: id, objectName: objectName, objectType: objectType, status: status, quantity: data.quantity, priceAtTimeOfSale: data.priceAtTimeOfSale, description: data.description, jobId: data.jobId, productId: data.productId)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
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
    let lineItemIds: [String]?
    enum CodingKeys: String, CodingKey {
        case quoteNumber = "quote_number"
        case customerId = "customer_id"
        case pricebookId = "pricebook_id"
        case totalAmount = "total_amount"
        case quoteStatus = "quote_status"
        case preparedBy = "prepared_by"
        case lineItemIds = "line_item_ids"
        case currency
        case notes
    }
}

struct QuoteRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: QuoteData
    static let databaseTableName = "quotes"
    var model: Quote {
        Quote(id: id, objectName: objectName, objectType: objectType, status: status, quoteNumber: data.quoteNumber, customerId: data.customerId, pricebookId: data.pricebookId, totalAmount: data.totalAmount, currency: data.currency, quoteStatus: data.quoteStatus, notes: data.notes, preparedBy: data.preparedBy, lineItemIds: data.lineItemIds)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct ObjectFeedData: Codable, Hashable {
    let relatedObjectName: String
    let relatedRecordId: String
    let entryType: String
    let message: String?
    let authorId: String?
    let attachmentIds: [String]?
    enum CodingKeys: String, CodingKey {
        case relatedObjectName = "related_object_name"
        case relatedRecordId = "related_record_id"
        case entryType = "entry_type"
        case authorId = "author_id"
        case attachmentIds = "attachment_ids"
        case message
    }
}

struct ObjectFeedRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: ObjectFeedData
    static let databaseTableName = "object_feeds"
    var model: ObjectFeed {
        ObjectFeed(id: id, objectName: objectName, objectType: objectType, status: status, relatedObjectName: data.relatedObjectName, relatedRecordId: data.relatedRecordId, entryType: data.entryType, message: data.message, authorId: data.authorId, attachmentIds: data.attachmentIds)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
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
    let lineItemIds: [String]?
    enum CodingKeys: String, CodingKey {
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
        case lineItemIds = "line_item_ids"
        case currency
        case notes
    }
}

struct InvoiceRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: InvoiceData
    static let databaseTableName = "invoices"
    var model: Invoice {
        Invoice(id: id, objectName: objectName, objectType: objectType, status: status, invoiceNumber: data.invoiceNumber, customerId: data.customerId, jobId: data.jobId, quoteId: data.quoteId, subtotalAmount: data.subtotalAmount, taxAmount: data.taxAmount, discountAmount: data.discountAmount, totalAmount: data.totalAmount, currency: data.currency, issueDate: data.issueDate, dueDate: data.dueDate, paymentStatus: data.paymentStatus, notes: data.notes, issuedBy: data.issuedBy, lineItemIds: data.lineItemIds)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
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
        case priceAtTimeOfInvoice = "price_at_time_of_invoice"
        case invoiceId = "invoice_id"
        case productId = "product_id"
        case taxRate = "tax_rate"
        case discountAmount = "discount_amount"
        case quantity
        case description
    }
}

struct InvoiceLineItemRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String
    let status: String
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    let objectName: String
    let objectType: String
    let data: InvoiceLineItemData
    static let databaseTableName = "invoice_line_items"
    var model: InvoiceLineItem {
        InvoiceLineItem(id: id, objectName: objectName, objectType: objectType, status: status, quantity: data.quantity, priceAtTimeOfInvoice: data.priceAtTimeOfInvoice, description: data.description, invoiceId: data.invoiceId, productId: data.productId, taxRate: data.taxRate, discountAmount: data.discountAmount)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case objectName = "object_name"
        case objectType = "object_type"
        case id
        case status
        case version
        case data
    }
}

struct FieldDefinition: Codable, Hashable {
    let name: String
    let label: String
    let type: String
    let required: Bool?
    let format: String?
    let options: [String]?
    let targetObject: String?
    enum CodingKeys: String, CodingKey {
        case targetObject = "target_object"
        case name
        case label
        case type
        case required
        case format
        case options
    }
}

struct ObjectMetadataData: Codable, Hashable {
    let fieldDefinitions: [FieldDefinition]
    enum CodingKeys: String, CodingKey {
        case fieldDefinitions = "field_definitions"
    }
}

struct ObjectMetadataRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String?
    let objectName: String
    let data: ObjectMetadataData
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    static let databaseTableName = "object_metadata"
    var model: ObjectMetadata {
        ObjectMetadata(id: id, objectName: objectName, fieldDefinitions: data.fieldDefinitions)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case id
        case data
        case version
    }
}

struct LayoutSection: Codable, Hashable {
    let label: String
    let fields: [String]
    enum CodingKeys: String, CodingKey {
        case label
        case fields
    }
}

struct LayoutDefinitionData: Codable, Hashable {
    let sections: [LayoutSection]
    enum CodingKeys: String, CodingKey {
        case sections
    }
}

struct LayoutDefinitionRecord: Codable, Hashable, FetchableRecord, PersistableRecord {
    let id: String
    let tenantId: String?
    let objectName: String
    let objectType: String
    let status: String
    let data: LayoutDefinitionData
    let version: Double
    let createdBy: String?
    let modifiedBy: String?
    let createdAt: String
    let updatedAt: String
    static let databaseTableName = "layout_definitions"
    var model: LayoutDefinition {
        LayoutDefinition(id: id, objectName: objectName, objectType: objectType, status: status, sections: data.sections)
    }
    enum CodingKeys: String, CodingKey {
        case tenantId = "tenant_id"
        case objectName = "object_name"
        case objectType = "object_type"
        case createdBy = "created_by"
        case modifiedBy = "modified_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case id
        case status
        case data
        case version
    }
}

struct SyncResponse: Codable, Hashable {
    let meta: Meta
    let data: ResponseData
    enum CodingKeys: String, CodingKey {
        case meta
        case data
    }
}

struct Meta: Codable, Hashable {
    let serverTime: String
    let since: String
    enum CodingKeys: String, CodingKey {
        case serverTime = "server_time"
        case since
    }
}

struct ResponseData: Codable, Hashable {
    let users: [UserRecord]
    let customers: [CustomerRecord]
    let jobs: [JobRecord]
    let calendarEvents: [CalendarEventRecord]
    let pricebooks: [PricebookRecord]
    let products: [ProductRecord]
    let locations: [LocationRecord]
    let productItems: [ProductItemRecord]
    let pricebookEntries: [PricebookEntryRecord]
    let jobLineItems: [JobLineItemRecord]
    let quotes: [QuoteRecord]
    let objectFeeds: [ObjectFeedRecord]
    let invoices: [InvoiceRecord]
    let invoiceLineItems: [InvoiceLineItemRecord]
    let objectMetadata: [ObjectMetadataRecord]
    let layoutDefinitions: [LayoutDefinitionRecord]
    enum CodingKeys: String, CodingKey {
        case calendarEvents = "calendar_events"
        case productItems = "product_items"
        case pricebookEntries = "pricebook_entries"
        case jobLineItems = "job_line_items"
        case objectFeeds = "object_feeds"
        case invoiceLineItems = "invoice_line_items"
        case objectMetadata = "object_metadata"
        case layoutDefinitions = "layout_definitions"
        case users
        case customers
        case jobs
        case pricebooks
        case products
        case locations
        case quotes
        case invoices
    }
}

struct Base: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        }
    }
}

struct Job: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let jobNumber: String
    let customerId: String
    let jobAddress: Address?
    let jobDescription: String?
    let assignedTechId: String?
    let statusNote: String?
    let quoteId: String?
    let equipmentId: String?

    enum Field: String, Hashable, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case jobNumber
        case customerId
        case jobAddress
        case jobDescription
        case assignedTechId
        case statusNote
        case quoteId
        case equipmentId

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .jobNumber: return "job_number"
            case .customerId: return "customer_id"
            case .jobAddress: return "job_address"
            case .jobDescription: return "job_description"
            case .assignedTechId: return "assigned_tech_id"
            case .statusNote: return "status_note"
            case .quoteId: return "quote_id"
            case .equipmentId: return "equipment_id"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "job_number", "jobNumber":
                return .jobNumber
            case "customer_id", "customerId":
                return .customerId
            case "job_address", "jobAddress":
                return .jobAddress
            case "job_description", "jobDescription":
                return .jobDescription
            case "assigned_tech_id", "assignedTechId":
                return .assignedTechId
            case "status_note", "statusNote":
                return .statusNote
            case "quote_id", "quoteId":
                return .quoteId
            case "equipment_id", "equipmentId":
                return .equipmentId
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .jobNumber: return jobNumber
        case .customerId: return customerId
        case .jobAddress: return jobAddress
        case .jobDescription: return jobDescription
        case .assignedTechId: return assignedTechId
        case .statusNote: return statusNote
        case .quoteId: return quoteId
        case .equipmentId: return equipmentId
        }
    }
}

struct Tenant: Identifiable, Hashable {
    let id: String
    let name: String
    let plan: String

    enum Field: String, CaseIterable {
        case id
        case name
        case plan

        var key: String {
            switch self {
            case .id: return "id"
            case .name: return "name"
            case .plan: return "plan"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "name":
                return .name
            case "plan":
                return .plan
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .name: return name
        case .plan: return plan
        }
    }
}

struct User: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let email: String
    let displayName: String
    let role: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case email
        case displayName
        case role

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .email: return "email"
            case .displayName: return "display_name"
            case .role: return "role"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "email":
                return .email
            case "display_name", "displayName":
                return .displayName
            case "role":
                return .role
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .email: return email
        case .displayName: return displayName
        case .role: return role
        }
    }
}

struct Customer: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let name: String
    let contact: ContactInfo?
    let address: Address?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case name
        case contact
        case address

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .name: return "name"
            case .contact: return "contact"
            case .address: return "address"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "name":
                return .name
            case "contact":
                return .contact
            case "address":
                return .address
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .name: return name
        case .contact: return contact
        case .address: return address
        }
    }
}

struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let title: String
    let startTime: String
    let endTime: String
    let isAllDay: Bool?
    let jobId: String?
    let userId: String?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case title
        case startTime
        case endTime
        case isAllDay
        case jobId
        case userId

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .title: return "title"
            case .startTime: return "start_time"
            case .endTime: return "end_time"
            case .isAllDay: return "is_all_day"
            case .jobId: return "job_id"
            case .userId: return "user_id"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "title":
                return .title
            case "start_time", "startTime":
                return .startTime
            case "end_time", "endTime":
                return .endTime
            case "is_all_day", "isAllDay":
                return .isAllDay
            case "job_id", "jobId":
                return .jobId
            case "user_id", "userId":
                return .userId
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .title: return title
        case .startTime: return startTime
        case .endTime: return endTime
        case .isAllDay: return isAllDay
        case .jobId: return jobId
        case .userId: return userId
        }
    }
}

struct Pricebook: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let name: String
    let description: String?
    let isActive: Bool
    let currency: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case name
        case description
        case isActive
        case currency

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .name: return "name"
            case .description: return "description"
            case .isActive: return "is_active"
            case .currency: return "currency"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "name":
                return .name
            case "description":
                return .description
            case "is_active", "isActive":
                return .isActive
            case "currency":
                return .currency
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .name: return name
        case .description: return description
        case .isActive: return isActive
        case .currency: return currency
        }
    }
}

struct Product: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let name: String
    let description: String?
    let productCode: String?
    let type: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case name
        case description
        case productCode
        case type

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .name: return "name"
            case .description: return "description"
            case .productCode: return "product_code"
            case .type: return "type"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "name":
                return .name
            case "description":
                return .description
            case "product_code", "productCode":
                return .productCode
            case "type":
                return .type
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .name: return name
        case .description: return description
        case .productCode: return productCode
        case .type: return type
        }
    }
}

struct Location: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let name: String
    let address: Address?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case name
        case address

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .name: return "name"
            case .address: return "address"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "name":
                return .name
            case "address":
                return .address
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .name: return name
        case .address: return address
        }
    }
}

struct ProductItem: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let quantityOnHand: Double
    let productId: String
    let locationId: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case quantityOnHand
        case productId
        case locationId

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .quantityOnHand: return "quantity_on_hand"
            case .productId: return "product_id"
            case .locationId: return "location_id"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "quantity_on_hand", "quantityOnHand":
                return .quantityOnHand
            case "product_id", "productId":
                return .productId
            case "location_id", "locationId":
                return .locationId
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .quantityOnHand: return quantityOnHand
        case .productId: return productId
        case .locationId: return locationId
        }
    }
}

struct PricebookEntry: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let price: Double
    let currency: String
    let pricebookId: String
    let productId: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case price
        case currency
        case pricebookId
        case productId

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .price: return "price"
            case .currency: return "currency"
            case .pricebookId: return "pricebook_id"
            case .productId: return "product_id"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "price":
                return .price
            case "currency":
                return .currency
            case "pricebook_id", "pricebookId":
                return .pricebookId
            case "product_id", "productId":
                return .productId
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .price: return price
        case .currency: return currency
        case .pricebookId: return pricebookId
        case .productId: return productId
        }
    }
}

struct JobLineItem: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let quantity: Double
    let priceAtTimeOfSale: Double
    let description: String?
    let jobId: String
    let productId: String

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case quantity
        case priceAtTimeOfSale
        case description
        case jobId
        case productId

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .quantity: return "quantity"
            case .priceAtTimeOfSale: return "price_at_time_of_sale"
            case .description: return "description"
            case .jobId: return "job_id"
            case .productId: return "product_id"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "quantity":
                return .quantity
            case "price_at_time_of_sale", "priceAtTimeOfSale":
                return .priceAtTimeOfSale
            case "description":
                return .description
            case "job_id", "jobId":
                return .jobId
            case "product_id", "productId":
                return .productId
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .quantity: return quantity
        case .priceAtTimeOfSale: return priceAtTimeOfSale
        case .description: return description
        case .jobId: return jobId
        case .productId: return productId
        }
    }
}

struct Quote: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let quoteNumber: String
    let customerId: String
    let pricebookId: String?
    let totalAmount: Double
    let currency: String
    let quoteStatus: String
    let notes: String?
    let preparedBy: String?
    let lineItemIds: [String]?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case quoteNumber
        case customerId
        case pricebookId
        case totalAmount
        case currency
        case quoteStatus
        case notes
        case preparedBy
        case lineItemIds

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .quoteNumber: return "quote_number"
            case .customerId: return "customer_id"
            case .pricebookId: return "pricebook_id"
            case .totalAmount: return "total_amount"
            case .currency: return "currency"
            case .quoteStatus: return "quote_status"
            case .notes: return "notes"
            case .preparedBy: return "prepared_by"
            case .lineItemIds: return "line_item_ids"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "quote_number", "quoteNumber":
                return .quoteNumber
            case "customer_id", "customerId":
                return .customerId
            case "pricebook_id", "pricebookId":
                return .pricebookId
            case "total_amount", "totalAmount":
                return .totalAmount
            case "currency":
                return .currency
            case "quote_status", "quoteStatus":
                return .quoteStatus
            case "notes":
                return .notes
            case "prepared_by", "preparedBy":
                return .preparedBy
            case "line_item_ids", "lineItemIds":
                return .lineItemIds
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .quoteNumber: return quoteNumber
        case .customerId: return customerId
        case .pricebookId: return pricebookId
        case .totalAmount: return totalAmount
        case .currency: return currency
        case .quoteStatus: return quoteStatus
        case .notes: return notes
        case .preparedBy: return preparedBy
        case .lineItemIds: return lineItemIds
        }
    }
}

struct ObjectFeed: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let relatedObjectName: String
    let relatedRecordId: String
    let entryType: String
    let message: String?
    let authorId: String?
    let attachmentIds: [String]?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case relatedObjectName
        case relatedRecordId
        case entryType
        case message
        case authorId
        case attachmentIds

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .relatedObjectName: return "related_object_name"
            case .relatedRecordId: return "related_record_id"
            case .entryType: return "entry_type"
            case .message: return "message"
            case .authorId: return "author_id"
            case .attachmentIds: return "attachment_ids"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "related_object_name", "relatedObjectName":
                return .relatedObjectName
            case "related_record_id", "relatedRecordId":
                return .relatedRecordId
            case "entry_type", "entryType":
                return .entryType
            case "message":
                return .message
            case "author_id", "authorId":
                return .authorId
            case "attachment_ids", "attachmentIds":
                return .attachmentIds
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .relatedObjectName: return relatedObjectName
        case .relatedRecordId: return relatedRecordId
        case .entryType: return entryType
        case .message: return message
        case .authorId: return authorId
        case .attachmentIds: return attachmentIds
        }
    }
}

struct Invoice: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
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
    let lineItemIds: [String]?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case invoiceNumber
        case customerId
        case jobId
        case quoteId
        case subtotalAmount
        case taxAmount
        case discountAmount
        case totalAmount
        case currency
        case issueDate
        case dueDate
        case paymentStatus
        case notes
        case issuedBy
        case lineItemIds

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .invoiceNumber: return "invoice_number"
            case .customerId: return "customer_id"
            case .jobId: return "job_id"
            case .quoteId: return "quote_id"
            case .subtotalAmount: return "subtotal_amount"
            case .taxAmount: return "tax_amount"
            case .discountAmount: return "discount_amount"
            case .totalAmount: return "total_amount"
            case .currency: return "currency"
            case .issueDate: return "issue_date"
            case .dueDate: return "due_date"
            case .paymentStatus: return "payment_status"
            case .notes: return "notes"
            case .issuedBy: return "issued_by"
            case .lineItemIds: return "line_item_ids"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "invoice_number", "invoiceNumber":
                return .invoiceNumber
            case "customer_id", "customerId":
                return .customerId
            case "job_id", "jobId":
                return .jobId
            case "quote_id", "quoteId":
                return .quoteId
            case "subtotal_amount", "subtotalAmount":
                return .subtotalAmount
            case "tax_amount", "taxAmount":
                return .taxAmount
            case "discount_amount", "discountAmount":
                return .discountAmount
            case "total_amount", "totalAmount":
                return .totalAmount
            case "currency":
                return .currency
            case "issue_date", "issueDate":
                return .issueDate
            case "due_date", "dueDate":
                return .dueDate
            case "payment_status", "paymentStatus":
                return .paymentStatus
            case "notes":
                return .notes
            case "issued_by", "issuedBy":
                return .issuedBy
            case "line_item_ids", "lineItemIds":
                return .lineItemIds
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .invoiceNumber: return invoiceNumber
        case .customerId: return customerId
        case .jobId: return jobId
        case .quoteId: return quoteId
        case .subtotalAmount: return subtotalAmount
        case .taxAmount: return taxAmount
        case .discountAmount: return discountAmount
        case .totalAmount: return totalAmount
        case .currency: return currency
        case .issueDate: return issueDate
        case .dueDate: return dueDate
        case .paymentStatus: return paymentStatus
        case .notes: return notes
        case .issuedBy: return issuedBy
        case .lineItemIds: return lineItemIds
        }
    }
}

struct InvoiceLineItem: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let quantity: Double
    let priceAtTimeOfInvoice: Double
    let description: String?
    let invoiceId: String
    let productId: String
    let taxRate: Double?
    let discountAmount: Double?

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case quantity
        case priceAtTimeOfInvoice
        case description
        case invoiceId
        case productId
        case taxRate
        case discountAmount

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .quantity: return "quantity"
            case .priceAtTimeOfInvoice: return "price_at_time_of_invoice"
            case .description: return "description"
            case .invoiceId: return "invoice_id"
            case .productId: return "product_id"
            case .taxRate: return "tax_rate"
            case .discountAmount: return "discount_amount"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "quantity":
                return .quantity
            case "price_at_time_of_invoice", "priceAtTimeOfInvoice":
                return .priceAtTimeOfInvoice
            case "description":
                return .description
            case "invoice_id", "invoiceId":
                return .invoiceId
            case "product_id", "productId":
                return .productId
            case "tax_rate", "taxRate":
                return .taxRate
            case "discount_amount", "discountAmount":
                return .discountAmount
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .quantity: return quantity
        case .priceAtTimeOfInvoice: return priceAtTimeOfInvoice
        case .description: return description
        case .invoiceId: return invoiceId
        case .productId: return productId
        case .taxRate: return taxRate
        case .discountAmount: return discountAmount
        }
    }
}

struct ObjectMetadata: Identifiable, Hashable {
    let id: String
    let objectName: String
    let fieldDefinitions: [FieldDefinition]

    enum Field: String, CaseIterable {
        case id
        case objectName
        case fieldDefinitions

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .fieldDefinitions: return "field_definitions"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "field_definitions", "fieldDefinitions":
                return .fieldDefinitions
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .fieldDefinitions: return fieldDefinitions
        }
    }
}

struct LayoutDefinition: Identifiable, Hashable {
    let id: String
    let objectName: String
    let objectType: String
    let status: String
    let sections: [LayoutSection]

    enum Field: String, CaseIterable {
        case id
        case objectName
        case objectType
        case status
        case sections

        var key: String {
            switch self {
            case .id: return "id"
            case .objectName: return "object_name"
            case .objectType: return "object_type"
            case .status: return "status"
            case .sections: return "sections"
            }
        }

        static func from(name: String) -> Field? {
            switch name {
            case "id":
                return .id
            case "object_name", "objectName":
                return .objectName
            case "object_type", "objectType":
                return .objectType
            case "status":
                return .status
            case "sections":
                return .sections
            default:
                return nil
            }
        }
    }

    func value(for field: Field) -> Any? {
        switch field {
        case .id: return id
        case .objectName: return objectName
        case .objectType: return objectType
        case .status: return status
        case .sections: return sections
        }
    }
}
