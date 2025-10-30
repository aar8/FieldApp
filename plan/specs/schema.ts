/**
 * A marker interface to indicate a field should be stored as JSON in SQL.
 * The phantom property `__sql_json_brand` holds the underlying type.
 * @api skip
 * @db skip
 */
interface SqlJson<T> {
  __sql_json_brand: T;
}

/**
 * Represents a foreign key reference. It is structurally a string,
 * but the phantom property `__reference_brand` holds the referenced record's type,
 * allowing the generator to create foreign key constraints.
 * @api skip
 * @db skip
 */
interface Reference<T> {
  __reference_brand: T;
}

/**
 * Base interface for common fields across all synchronized tables.
 * @api skip
 * @db skip
 */
interface BaseRecord {
  /** The unique identifier for the record (UUID). */
  id: string;

  /** The ID of the tenant this record belongs to. */
  tenant_id: Reference<TenantRecord>;

  /** The current domain-specific status of the record (e.g., 'scheduled', 'active'). */
  status: string; // Consider using specific string literal unions later (e.g., JobStatus)

  /** Optimistic concurrency control version number. Incremented on each update. */
  version: number;

  /** The ID of the user who created this record. Optional. */
  created_by?: Reference<UserRecord>;

  /** The ID of the user who last modified this record. Optional. */
  modified_by?: Reference<UserRecord>;

  /** ISO 8601 timestamp string of when the record was created. */
  created_at: string;

  /** ISO 8601 timestamp string of when the record was last updated. */
  updated_at: string;

  /** The primary object name for this record (e.g., 'job', 'customer'). */
  object_name: string;

  /** The specific sub-type of the record (e.g., 'job_residential_tuneup'). */
  object_type: string;

  /** The JSON payload for this record. Subtypes should narrow this type. */
  data: SqlJson<any>;
}

/**
 * Defines the structure of the JSON 'data' blob specifically for Job records.
 * @api only
 */
interface JobData {
  /** The unique, human-readable identifier for the job (e.g., "J-1024"). */
  job_number: string;

  /** The ID of the customer associated with this job. */
  customer_id: Reference<CustomerRecord>;

  /** The primary address where the job will be performed. */
  job_address?: string;

  /** A description of the work requested or the problem reported. */
  job_description?: string;

  /** The ID of the primary technician assigned to this job. */
  assigned_tech_id?: Reference<UserRecord>;

  /** A short note reflecting the latest status update (e.g., "Tech en route"). Optional. */
  status_note?: string;

  /** The ID of the quote this job was generated from. (QuoteRecord not yet defined). */
  quote_id?: string;

  /** The ID of the primary customer equipment being serviced. */
  equipment_id?: Reference<CustomerEquipmentRecord>;
}

/**
 * Represents a Job record, combining base fields with job-specific data.
 */
interface JobRecord extends BaseRecord {
  /** The primary object name, always 'job' for this table. */
  object_name: 'job'; // Using literal type for clarity

  /** The specific sub-type of the job (e.g., "job_residential_tuneup", "job_commercial_install"). */
  object_type: string; // Should reference a record_type_metadata table eventually

  /** The job-specific payload, stored as JSON. */
  data: SqlJson<JobData>;
}


/**
### `tenants`

This table holds information about each **customer company** using the software (e.g., "Cool HVAC LLC"). It's the top-level container ensuring that each company's data (jobs, users, customers) is kept separate. Think of it like assigning each company its own private section within the database.
*/

/**
 * Defines the structure of the JSON 'data' blob specifically for Tenant records.
 * @api skip
 * @db skip
 */
interface TenantData {
  /** The name of the tenant organization. */
  name: string;

  /** The subscription plan for the tenant (e.g., "pro", "free"). */
  plan: string;
}

/**
 * Represents a Tenant record. It does not extend BaseRecord as tenants are the top-level entity.
 * @api skip
 * @db skip
 */
interface TenantRecord {
  /** The unique identifier for the record (UUID). */
  id: string;

  /** The tenant-specific payload, stored as JSON. */
  data: SqlJson<TenantData>;

  /** Optimistic concurrency control version number. Incremented on each update. */
  version: number;

  /** The ID of the user who created this record. Optional. */
  created_by?: Reference<UserRecord>;

  /** The ID of the user who last modified this record. Optional. */
  modified_by?: Reference<UserRecord>;

  /** ISO 8601 timestamp string of when the record was created. */
  created_at: string;

  /** ISO 8601 timestamp string of when the record was last updated. */
  updated_at: string;
}

/**
### `users`

This table stores login information and details for **individual people** who use the software within a specific company (tenant). This includes administrators managing the system, technicians out in the field, and dispatchers scheduling jobs. Each user belongs to one tenant. 👤
*/

/**
 * Defines the structure of the JSON 'data' blob specifically for User records.
 * @api only
 */
interface UserData {
  /** The user's email address. */
  email: string;

  /** The user's display name. */
  display_name: string;

  /** The user's role within the system. */
  role: 'tech' | 'admin' | 'dispatcher' | 'owner';
}

/**
 * Represents a User record, combining base fields with user-specific data.
 */
interface UserRecord extends BaseRecord {
  /** The primary object name, always 'user' for this table. */
  object_name: 'user';

  /** The specific sub-type of the user. */
  object_type: string; // Should reference a record_type_metadata table eventually

  /** The user-specific payload, stored as JSON. */
  data: SqlJson<UserData>;
}

// ---

/**
 * Represents contact information.
 * @api only
 */
interface ContactInfo {
  email?: string;
  phone?: string;
}

/**
 * Represents a physical address.
 * @api only
 */
interface Address {
  street?: string;
  city?: string;
  state?: string;
  zip_code?: string;
  country?: string;
}

/**
### `customers`

This table stores information about the **end clients** who receive services from the tenant companies (e.g., homeowners, businesses). It holds details like names, addresses, and contact information. Each customer record belongs to one tenant. 🏠
*/

/**
 * Defines the structure of the JSON 'data' blob specifically for Customer records.
 * @api only
 */
interface CustomerData {
  /** The name of the customer. */
  name: string;

  /** Contact information for the customer. */
  contact?: ContactInfo;

  /** The primary address for the customer. */
  address?: Address;
}

/**
 * Represents a Customer record, combining base fields with customer-specific data.
 */
interface CustomerRecord extends BaseRecord {
  /** The primary object name, always 'customer' for this table. */
  object_name: 'customer';

  /** The specific sub-type of the customer. */
  object_type: string; // Should reference a record_type_metadata table eventually

  /** The customer-specific payload, stored as JSON. */
  data: SqlJson<CustomerData>;
}

// ---

/**
### `calendar_events`

This table tracks **time blocks** on the schedule for users (technicians). It can represent a scheduled **job appointment**, but also other events like travel time, meetings, or paid time off. This helps manage technician availability and plan routes. 📅
*/

/**
 * Defines the structure of the JSON 'data' blob for Calendar Event records.
 * @api only
 */
interface CalendarEventData {
  /** The title of the event. */
  title: string;

  /** The start time of the event in ISO 8601 format. */
  start_time: string;

  /** The end time of the event in ISO 8601 format. */
  end_time: string;

  /** Whether the event is an all-day event. */
  is_all_day?: boolean;

  /** The ID of the job this event is associated with. */
  job_id?: Reference<JobRecord>;

  /** The ID of the user this event is associated with. */
  user_id?: Reference<UserRecord>;
}

/**
 * Represents a Calendar Event record.
 */
interface CalendarEventRecord extends BaseRecord {
  object_name: 'calendar_event';
  object_type: string;
  data: SqlJson<CalendarEventData>;
}

// ---

/**
### `pricebooks`

This table defines different **collections of prices**. A company might have a standard pricebook, a commercial pricebook, or special pricing for certain customer groups. It allows for flexible pricing strategies. 💰
*/

/**
 * Defines the structure of the JSON 'data' blob for Pricebook records.
 * @api only
 */
interface PricebookData {
  /** The name of the pricebook. */
  name: string;

  /** A description of the pricebook. */
  description?: string;

  /** Whether the pricebook is active. */
  is_active: boolean;

  /** The currency code for the prices in this pricebook (e.g., "USD"). */
  currency: string;
}

/**
 * Represents a Pricebook record.
 */
interface PricebookRecord extends BaseRecord {
  object_name: 'pricebook';
  object_type: string;
  data: SqlJson<PricebookData>;
}

// ---

/**
### `products`

This table is the master **catalog** of everything a tenant company sells or uses. This includes **services** (like "Standard AC Tuneup"), physical **parts/goods** (like a specific compressor model), and different types of **labor** (like "Standard Hourly Rate"). A type field distinguishes between these categories, enabling different logic (e.g., only physical goods affect inventory). 🏷️
*/

/**
 * Defines the structure of the JSON 'data' blob for Product records.
 * @api only
 */
interface ProductData {
  /** The name of the product. */
  name: string;

  /** A description of the product. */
  description?: string;

  /** The product's stock keeping unit (SKU) or other code. */
  product_code?: string;

  /** The type of product. */
  type: 'service' | 'material';
}

/**
 * Represents a Product record.
 */
interface ProductRecord extends BaseRecord {
  object_name: 'product';
  object_type: string;
  data: SqlJson<ProductData>;
}

// ---

/**
### `locations`

This table defines physical places where inventory is kept, such as a **main warehouse** or a specific **technician's service van**. 🚚
*/

/**
 * Defines the structure of the JSON 'data' blob for Location records.
 * @api only
 */
interface LocationData {
  /** The name of the location (e.g., "Main Warehouse", "Van 12"). */
  name: string;

  /** The address of the location. */
  address?: Address;
}

/**
 * Represents a Location record.
 */
interface LocationRecord extends BaseRecord {
  object_name: 'location';
  object_type: string;
  data: SqlJson<LocationData>;
}

// ---

/**
### `product_items`

This table tracks the **quantity on hand** of a specific physical **product** (part) at a specific **location**. This is the core inventory record, showing how many compressors Tech Bob has in his van. 📦
*/

/**
 * Defines the structure of the JSON 'data' blob for Product Item records.
 * @api only
 */
interface ProductItemData {
  /** The quantity of the product on hand at a specific location. */
  quantity_on_hand: number;

  /** The ID of the product. */
  product_id: Reference<ProductRecord>;

  /** The ID of the location where the product is stored. */
  location_id: Reference<LocationRecord>;
}

/**
 * Represents a Product Item record, tracking inventory.
 */
interface ProductItemRecord extends BaseRecord {
  object_name: 'product_item';
  object_type: string;
  data: SqlJson<ProductItemData>;
}

// ---

/**
### `pricebook_entries`

This table links a specific **product** to a specific **pricebook** and defines its **price** within that book. For example, the "Standard AC Tuneup" product might cost $150 in the "Residential" pricebook but $200 in the "Commercial" pricebook. 💲
*/

/**
 * Defines the structure of the JSON 'data' blob for Pricebook Entry records.
 * @api only
 */
interface PricebookEntryData {
  /** The price of the product. */
  price: number;

  /** The currency of the price. */
  currency: string;

  /** The ID of the pricebook this entry belongs to. */
  pricebook_id: Reference<PricebookRecord>;

  /** The ID of the product this entry defines the price for. */
  product_id: Reference<ProductRecord>;
}

/**
 * Represents a Pricebook Entry record.
 */
interface PricebookEntryRecord extends BaseRecord {
  object_name: 'pricebook_entry';
  object_type: string;
  data: SqlJson<PricebookEntryData>;
}

// ---

/**
### `job_line_items`

This table represents a specific **product** (service, part, or labor) that was added to a **job**. It includes the quantity used and the price charged for that item on that specific job. These lines often form the basis for creating customer invoices. 📝
*/

/**
 * Defines the structure of the JSON 'data' blob for Job Line Item records.
 * @api only
 */
interface JobLineItemData {
  /** The quantity of the product or service used. */
  quantity: number;

  /** The price at the time of sale, capturing historical price. */
  price_at_time_of_sale: number;

  /** A description of the line item, which can override the product's default description. */
  description?: string;

  /** The ID of the job this line item belongs to. */
  job_id: Reference<JobRecord>;

  /** The ID of the product being used or sold. */
  product_id: Reference<ProductRecord>;
}

/**
 * Represents a Job Line Item record.
 */
interface JobLineItemRecord extends BaseRecord {
  object_name: 'job_line_item';
  object_type: string;
  data: SqlJson<JobLineItemData>;
}

/**
 * Defines the structure of the JSON 'data' blob for Quote records.
 * @api only
 */
interface QuoteData {
  /** A human-readable quote number (e.g., "Q-203"). */
  quote_number: string;

  /** The ID of the customer receiving this quote. */
  customer_id: Reference<CustomerRecord>;

  /** The ID of the pricebook used to calculate pricing for this quote. */
  pricebook_id?: Reference<PricebookRecord>;

  /** The total price of the quote, including all line items. */
  total_amount: number;

  /** The currency used for this quote. */
  currency: string;

  /** The status of the quote (e.g., "draft", "sent", "accepted", "rejected"). */
  quote_status: 'draft' | 'sent' | 'accepted' | 'rejected';

  /** Optional freeform notes from the preparer. */
  notes?: string;

  /** The ID of the user (typically a salesperson) who prepared this quote. */
  prepared_by?: Reference<UserRecord>;

  /** The IDs of the quote line items belonging to this quote. */
  line_item_ids?: Reference<QuoteLineItemRecord[];
}

/**
 * Represents a Quote record.
 */
interface QuoteRecord extends BaseRecord {
  object_name: 'quote';
  object_type: string;
  data: SqlJson<QuoteData>;
}

/**
 * Defines the structure of the JSON 'data' blob for Object Feed records.
 * @api only
 */
interface ObjectFeedData {
  /** The target record that this feed entry is associated with. */
  related_object_name: string; // e.g., 'job', 'quote', 'customer'

  /** The ID of the record this feed entry belongs to. */
  related_record_id: string;

  /** The type of feed entry (e.g., 'comment', 'status_update', 'system_event'). */
  entry_type: 'comment' | 'status_update' | 'system_event' | 'attachment';

  /** The text body of the feed entry, if applicable. */
  message?: string;

  /** The ID of the user who authored this entry, if applicable. */
  author_id?: Reference<UserRecord>;

  /** An optional list of file IDs attached to this feed entry. */
  attachment_ids?: string[];
}

/**
 * Represents an Object Feed record.
 */
interface ObjectFeedRecord extends BaseRecord {
  object_name: 'object_feed';
  object_type: string;
  data: SqlJson<ObjectFeedData>;
}

/**
 * Defines the structure of the JSON 'data' blob for Invoice records.
 * @api only
 */
interface InvoiceData {
  /** A human-readable invoice number (e.g., "INV-1005"). */
  invoice_number: string;

  /** The ID of the customer being billed. */
  customer_id: Reference<CustomerRecord>;

  /** The ID of the job this invoice is based on. */
  job_id?: Reference<JobRecord>;

  /** The ID of the quote this invoice originated from, if applicable. */
  quote_id?: Reference<QuoteRecord>;

  /** The subtotal amount before taxes or discounts. */
  subtotal_amount: number;

  /** The total tax applied to the invoice. */
  tax_amount?: number;

  /** The total discount applied to the invoice. */
  discount_amount?: number;

  /** The final total after taxes and discounts. */
  total_amount: number;

  /** The currency used for this invoice (e.g., "USD"). */
  currency: string;

  /** The date the invoice was issued, in ISO 8601 format. */
  issue_date: string;

  /** The date the invoice is due, in ISO 8601 format. */
  due_date?: string;

  /** The current payment status of the invoice. */
  payment_status: 'draft' | 'sent' | 'paid' | 'partially_paid' | 'void' | 'overdue';

  /** Optional notes or terms shown on the invoice. */
  notes?: string;

  /** The ID of the user (e.g., admin) who issued the invoice. */
  issued_by?: Reference<UserRecord>;

  /** The IDs of the invoice line items included in this invoice. */
  line_item_ids?: Reference<InvoiceLineItemRecord[];
}

/**
 * Represents an Invoice record.
 */
interface InvoiceRecord extends BaseRecord {
  object_name: 'invoice';
  object_type: string;
  data: SqlJson<InvoiceData>;
}

/**
 * Defines the structure of the JSON 'data' blob for Invoice Line Item records.
 * @api only
 */
interface InvoiceLineItemData {
  /** The quantity of the product or service billed. */
  quantity: number;

  /** The price at the time of invoicing (historical snapshot). */
  price_at_time_of_invoice: number;

  /** Optional description for this specific invoice line. */
  description?: string;

  /** The ID of the invoice this line belongs to. */
  invoice_id: Reference<InvoiceRecord>;

  /** The ID of the product being invoiced. */
  product_id: Reference<ProductRecord>;

  /** Optional tax rate (e.g., 0.08 for 8%) applied to this line. */
  tax_rate?: number;

  /** Optional discount applied to this line item. */
  discount_amount?: number;
}

/**
 * Represents an Invoice Line Item record.
 */
interface InvoiceLineItemRecord extends BaseRecord {
  object_name: 'invoice_line_item';
  object_type: string;
  data: SqlJson<InvoiceLineItemData>;
}

// ---

/**
 * ### `object_metadata`
 *
 * **Purpose**: This table serves as the central schema definition for each business object within the system, identified by the `object_name` column (e.g., "job", "customer"). It defines the complete set of fields—both core system fields and tenant-defined custom fields—that constitute the data structure for that object.
 *
 * **Structure**:
 * - `object_name`: Specifies the target business object (e.g., "job", "customer", "invoice") whose fields are being defined.
 * - `data` (JSON): Contains a structured definition (e.g., an array or map) describing each field associated with the `object_name`. Each field definition includes attributes such as:
 *   - `field_name`: The key used within the main data table's JSON blob.
 *   - `data_type`: The expected data type (e.g., "text", "number", "date", "boolean", "lookup").
 *   - `label`: The user-facing display name for the field.
 *   - `is_required`: Boolean indicating if the field must have a value.
 *   - `is_core_field`: Boolean indicating if it's a standard system field or a custom addition.
 *   - Other properties like display order, help text, or validation rules.
 *
 * **Role in System**: This table is the single source of truth for the structure of business objects. It is read by various system components:
 * 1.  **Dynamic UI Engine**: Uses these definitions to render appropriate input fields, labels, and layouts in the client applications.
 * 2.  **Validation Logic**: Enforces data types and required field rules based on these definitions before saving data.
 * 3.  **Sync Engine**: May use this metadata to understand the structure of data being synchronized.
 * 4.  **API Layers**: Can use this to provide schema information to integrators.
 *
 * By centralizing the field definitions here, the system supports dynamic rendering, validation, and extensibility (adding new fields) without requiring changes to the core database table schemas.
 */

/**
 * Defines a single field in object metadata.
 * @api only
 */
interface FieldDefinition {
  name: string;
  label: string;
  type: 'string' | 'date' | 'picklist' | 'checkbox' | 'bool' | 'numeric' | 'currency' | 'reference' | 'file';
  required?: boolean;
  format?: 'email' | 'phone' | 'url';
  options?: string[];
  target_object?: string; // For 'reference' type
}

/**
 * Defines the structure of the JSON 'data' blob for Object Metadata records.
 * @api only
 */
interface ObjectMetadataData {
  /** The array of field definitions for the object. */
  field_definitions: FieldDefinition[];
}

/**
 * Represents a record in the `object_metadata` table.
 * These records are not standard business objects but are definitions that describe other objects.
 * Each record defines the schema for a business object like 'job' or 'customer'.
 */
interface ObjectMetadataRecord {
  /** The unique identifier for the metadata record itself. */
  id: string;

  /** The ID of the tenant this metadata belongs to. Can be null for global metadata. */
  tenant_id?: Reference<TenantRecord>;

  /** The name of the object whose schema is being defined (e.g., 'job', 'customer'). */
  object_name: string;

  /** The metadata payload, containing field definitions. */
  data: SqlJson<ObjectMetadataData>;

  /** Optimistic concurrency control version number. */
  version: number;

  /** The ID of the user who created this record. */
  created_by?: Reference<UserRecord>;

  /** The ID of the user who last modified this record. */
  modified_by?: Reference<UserRecord>;

  /** ISO 8601 timestamp of when the record was created. */
  created_at: string;

  /** ISO 8601 timestamp of when the record was last updated. */
  updated_at: string;
}

// ---

/**
 * Defines a section within a layout.
 * @api only
 */
interface LayoutSection {
  /** The user-visible label for the section. */
  label: string;
  /** The names of the fields included in this section, in order. */
  fields: string[];
}

/**
 * Defines the structure of the JSON 'data' blob for Layout Definition records.
 * @api only
 */
interface LayoutDefinitionData {
  /** The array of sections that make up the layout. */
  sections: LayoutSection[];
}

/**
 * ### `layout_definitions`
 *
 * **Purpose**: This table defines the visual structure and content (the layout) for displaying records in the user interface. It dictates which fields are shown, how they are grouped into sections, and in what order they appear. Crucially, it allows the UI to dynamically adapt based on the specific context of the record being viewed.
 *
 * **Structure**:
 * - `object_name`: Specifies the target business object (e.g., "job", "customer") whose layout is being defined.
 * - `object_type`: Specifies the sub-type of the object (e.g., "job_residential", "job_commercial", or a default like "*").
 * - `status`: Specifies the record status (e.g., "scheduled", "in_progress", or a default like "*").
 * - `data` (JSON): Contains the actual layout definition, structured as follows:
 *   - `sections`: An array of `LayoutSection` objects. Each section represents a distinct grouping of fields in the UI.
 *     - `label`: The user-visible title for the section (e.g., "Job Details", "Customer Information").
 *     - `fields`: An ordered array of field names. These names correspond to the `field_name` definitions found in the `object_metadata` table for the given `object_name`. The order in this array dictates the display order within the section.
 *
 * **Role in System**: This table is the blueprint for the UI.
 * 1.  **Dynamic UI Engine**: When displaying a record, the client application queries this table using the record's specific `object_name`, `object_type`, and `status`.
 * 2.  **Layout Selection**: The system finds the most specific matching `layout_definitions` record (using default "*" values if an exact match isn't found).
 * 3.  **Rendering**: The client then uses the `data` JSON (the `sections` and ordered `fields` arrays) from the selected layout record, combined with the field definitions from `object_metadata`, to dynamically construct and render the appropriate user interface on the screen.
 *
 * By binding layouts to this compound key (`object_name`, `object_type`, `status`), the system can present entirely different views and available fields for the same type of object depending on its specific state and classification (e.g., an "In Progress Residential Job" layout vs. a read-only "Completed Commercial Job" layout). 🎨
 */
/**
 * Represents a record in the `layout_definitions` table.
 * These records define the UI layout for a specific type of object in a specific status.
 */
interface LayoutDefinitionRecord {
  /** The unique identifier for the layout definition itself. */
  id: string;

  /** The ID of the tenant this layout belongs to. Can be null for global layouts. */
  tenant_id?: Reference<TenantRecord>;

  /** The name of the object this layout applies to (e.g., 'job', 'customer'). */
  object_name: string;

  /** The sub-type of the object this layout applies to (e.g., 'job_residential_tuneup', '*'). */
  object_type: string;

  /** The status of the object this layout applies to (e.g., 'scheduled', 'in_progress', '*'). */
  status: string;

  /** The layout definition payload, containing sections and fields. */
  data: SqlJson<LayoutDefinitionData>;

  /** Optimistic concurrency control version number. */
  version: number;

  /** The ID of the user who created this record. */
  created_by?: Reference<UserRecord>;

  /** The ID of the user who last modified this record. */
  modified_by?: Reference<UserRecord>;

  /** ISO 8601 timestamp of when the record was created. */
  created_at: string;

  /** ISO 8601 timestamp of when the record was last updated. */
  updated_at: string;
}

type IsoTimestamp = string;

/**
 * @api only
 */
interface SyncResponse {
  meta: Meta;
  data: ResponseData;
}

/**
 * @api only
 */
interface Meta {
    server_time: IsoTimestamp
    since: IsoTimestamp
}

/**
 * @api only
 */
interface ResponseData {
    users: UserRecord[];
    customers: CustomerRecord[];
    jobs: JobRecord[];
    calendar_events: CalendarEventRecord[];
    pricebooks: PricebookRecord[];
    products: ProductRecord[];
    locations: LocationData[];
    product_items: ProductItemRecord[];
    pricebook_entries: PricebookEntryRecord[];
    job_line_items: JobLineItemRecord[];
    quotes: QuoteRecord[];
    object_feeds: ObjectFeedRecord[];
    invoices: InvoiceRecord[];
    invoice_line_items: InvoiceLineItemRecord[];
    object_metadata: ObjectMetadataRecord[];
    layout_definitions: LayoutDefinitionRecord[];
}
