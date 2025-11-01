// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import Foundation
import GRDB


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
        Job(id: id, jobNumber: data.jobNumber, customerId: data.customerId, jobAddress: data.jobAddress, jobDescription: data.jobDescription, assignedTechId: data.assignedTechId, statusNote: data.statusNote, quoteId: data.quoteId, equipmentId: data.equipmentId)
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
        User(id: id, email: data.email, displayName: data.displayName, role: data.role)
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
        Customer(id: id, name: data.name, contact: data.contact, address: data.address)
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
        CalendarEvent(id: id, title: data.title, startTime: data.startTime, endTime: data.endTime, isAllDay: data.isAllDay, jobId: data.jobId, userId: data.userId)
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
        Pricebook(id: id, name: data.name, description: data.description, isActive: data.isActive, currency: data.currency)
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
        Product(id: id, name: data.name, description: data.description, productCode: data.productCode, type: data.type)
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
        Location(id: id, name: data.name, address: data.address)
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
        ProductItem(id: id, quantityOnHand: data.quantityOnHand, productId: data.productId, locationId: data.locationId)
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
        PricebookEntry(id: id, price: data.price, currency: data.currency, pricebookId: data.pricebookId, productId: data.productId)
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
        JobLineItem(id: id, quantity: data.quantity, priceAtTimeOfSale: data.priceAtTimeOfSale, description: data.description, jobId: data.jobId, productId: data.productId)
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
        Quote(id: id, quoteNumber: data.quoteNumber, customerId: data.customerId, pricebookId: data.pricebookId, totalAmount: data.totalAmount, currency: data.currency, quoteStatus: data.quoteStatus, notes: data.notes, preparedBy: data.preparedBy, lineItemIds: data.lineItemIds)
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
        ObjectFeed(id: id, relatedObjectName: data.relatedObjectName, relatedRecordId: data.relatedRecordId, entryType: data.entryType, message: data.message, authorId: data.authorId, attachmentIds: data.attachmentIds)
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
        Invoice(id: id, invoiceNumber: data.invoiceNumber, customerId: data.customerId, jobId: data.jobId, quoteId: data.quoteId, subtotalAmount: data.subtotalAmount, taxAmount: data.taxAmount, discountAmount: data.discountAmount, totalAmount: data.totalAmount, currency: data.currency, issueDate: data.issueDate, dueDate: data.dueDate, paymentStatus: data.paymentStatus, notes: data.notes, issuedBy: data.issuedBy, lineItemIds: data.lineItemIds)
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
        InvoiceLineItem(id: id, quantity: data.quantity, priceAtTimeOfInvoice: data.priceAtTimeOfInvoice, description: data.description, invoiceId: data.invoiceId, productId: data.productId, taxRate: data.taxRate, discountAmount: data.discountAmount)
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
        ObjectMetadata(id: id, fieldDefinitions: data.fieldDefinitions)
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
        LayoutDefinition(id: id, sections: data.sections)
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
}

struct Job: Identifiable, Hashable {
    let id: String
    let jobNumber: String
    let customerId: String
    let jobAddress: String?
    let jobDescription: String?
    let assignedTechId: String?
    let statusNote: String?
    let quoteId: String?
    let equipmentId: String?
}

struct Tenant: Identifiable, Hashable {
    let id: String
    let name: String
    let plan: String
}

struct User: Identifiable, Hashable {
    let id: String
    let email: String
    let displayName: String
    let role: String
}

struct Customer: Identifiable, Hashable {
    let id: String
    let name: String
    let contact: ContactInfo?
    let address: Address?
}

struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startTime: String
    let endTime: String
    let isAllDay: Bool?
    let jobId: String?
    let userId: String?
}

struct Pricebook: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let isActive: Bool
    let currency: String
}

struct Product: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String?
    let productCode: String?
    let type: String
}

struct Location: Identifiable, Hashable {
    let id: String
    let name: String
    let address: Address?
}

struct ProductItem: Identifiable, Hashable {
    let id: String
    let quantityOnHand: Double
    let productId: String
    let locationId: String
}

struct PricebookEntry: Identifiable, Hashable {
    let id: String
    let price: Double
    let currency: String
    let pricebookId: String
    let productId: String
}

struct JobLineItem: Identifiable, Hashable {
    let id: String
    let quantity: Double
    let priceAtTimeOfSale: Double
    let description: String?
    let jobId: String
    let productId: String
}

struct Quote: Identifiable, Hashable {
    let id: String
    let quoteNumber: String
    let customerId: String
    let pricebookId: String?
    let totalAmount: Double
    let currency: String
    let quoteStatus: String
    let notes: String?
    let preparedBy: String?
    let lineItemIds: [String]?
}

struct ObjectFeed: Identifiable, Hashable {
    let id: String
    let relatedObjectName: String
    let relatedRecordId: String
    let entryType: String
    let message: String?
    let authorId: String?
    let attachmentIds: [String]?
}

struct Invoice: Identifiable, Hashable {
    let id: String
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
}

struct InvoiceLineItem: Identifiable, Hashable {
    let id: String
    let quantity: Double
    let priceAtTimeOfInvoice: Double
    let description: String?
    let invoiceId: String
    let productId: String
    let taxRate: Double?
    let discountAmount: Double?
}

struct ObjectMetadata: Identifiable, Hashable {
    let id: String
    let fieldDefinitions: [FieldDefinition]
}

struct LayoutDefinition: Identifiable, Hashable {
    let id: String
    let sections: [LayoutSection]
}