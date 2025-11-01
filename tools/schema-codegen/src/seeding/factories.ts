import { randomUUID } from 'crypto';
import type {
  TenantRecord,
  TenantData,
  UserRecord,
  UserData,
  CustomerRecord,
  CustomerData,
  JobRecord,
  JobData,
  CalendarEventRecord,
  CalendarEventData,
  PricebookRecord,
  PricebookData,
  ProductRecord,
  ProductData,
  LocationRecord,
  ProductItemRecord,
  ProductItemData,
  PricebookEntryRecord,
  PricebookEntryData,
  JobLineItemRecord,
  JobLineItemData,
  QuoteRecord,
  QuoteData,
  ObjectFeedRecord,
  ObjectFeedData,
  InvoiceRecord,
  InvoiceData,
  InvoiceLineItemRecord,
  InvoiceLineItemData
} from '../../../../plan/specs/schema';

const now = () => new Date().toISOString();

export function tenant(args: { id?: string; data?: Partial<TenantData> } = {}): TenantRecord {
  return {
    id: args.id ?? randomUUID(),
    data: {
      name: 'Default Tenant',
      plan: 'pro',
      ...args.data
    },
    version: 0,
    created_at: now(),
    updated_at: now()
  };
}

export function user(args: { id?: string; data?: Partial<UserData> } = {}): UserRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'user',
    object_type: 'user_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      email: 'user@example.com',
      display_name: 'Default User',
      role: 'tech',
      ...args.data
    }
  };
}

export function customer(args: { id?: string; data?: Partial<CustomerData> } = {}): CustomerRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'customer',
    object_type: 'customer_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      name: 'Default Customer',
      contact: {},
      address: {},
      ...args.data
    }
  };
}

export function job(args: { id?: string; data?: Partial<JobData> } = {}): JobRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'job',
    object_type: 'job_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      job_number: `J-${Math.floor(Math.random() * 10000)}`,
      customer_id: '',
      ...args.data
    }
  };
}

export function calendarEvent(args: { id?: string; data?: Partial<CalendarEventData> } = {}): CalendarEventRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'calendar_event',
    object_type: 'calendar_event_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      title: 'Default Event',
      start_time: now(),
      end_time: now(),
      is_all_day: false,
      ...args.data
    }
  };
}

export function pricebook(args: { id?: string; data?: Partial<PricebookData> } = {}): PricebookRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'pricebook',
    object_type: 'pricebook_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      name: 'Default Pricebook',
      is_active: true,
      currency: 'USD',
      ...args.data
    }
  };
}

export function product(args: { id?: string; data?: Partial<ProductData> } = {}): ProductRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'product',
    object_type: 'product_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      name: 'Default Product',
      type: 'service',
      ...args.data
    }
  };
}

export function location(args: { id?: string; data?: Partial<LocationData> } = {}): LocationRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'location',
    object_type: 'location_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      name: 'Default Location',
      address: {},
      ...args.data
    }
  };
}

export function productItem(args: { id?: string; data?: Partial<ProductItemData> } = {}): ProductItemRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'product_item',
    object_type: 'product_item_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      quantity_on_hand: 0,
      product_id: '',
      location_id: '',
      ...args.data
    }
  };
}

export function pricebookEntry(args: { id?: string; data?: Partial<PricebookEntryData> } = {}): PricebookEntryRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'pricebook_entry',
    object_type: 'pricebook_entry_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      price: 0,
      currency: 'USD',
      pricebook_id: '',
      product_id: '',
      ...args.data
    }
  };
}

export function jobLineItem(args: { id?: string; data?: Partial<JobLineItemData> } = {}): JobLineItemRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'job_line_item',
    object_type: 'job_line_item_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      quantity: 1,
      price_at_time_of_sale: 0,
      job_id: '',
      product_id: '',
      ...args.data
    }
  };
}

export function quote(args: { id?: string; data?: Partial<QuoteData> } = {}): QuoteRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'quote',
    object_type: 'quote_default',
    status: 'draft',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      quote_number: `Q-${Math.floor(Math.random() * 10000)}`,
      customer_id: '',
      total_amount: 0,
      currency: 'USD',
      quote_status: 'draft',
      ...args.data
    }
  };
}

export function objectFeed(args: { id?: string; data?: Partial<ObjectFeedData> } = {}): ObjectFeedRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'object_feed',
    object_type: 'object_feed_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      related_object_name: '',
      related_record_id: '',
      entry_type: 'comment',
      ...args.data
    }
  };
}

export function invoice(args: { id?: string; data?: Partial<InvoiceData> } = {}): InvoiceRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'invoice',
    object_type: 'invoice_default',
    status: 'draft',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      invoice_number: `INV-${Math.floor(Math.random() * 10000)}`,
      customer_id: '',
      subtotal_amount: 0,
      total_amount: 0,
      currency: 'USD',
      issue_date: now(),
      payment_status: 'draft',
      ...args.data
    }
  };
}

export function invoiceLineItem(args: { id?: string; data?: Partial<InvoiceLineItemData> } = {}): InvoiceLineItemRecord {
  return {
    id: args.id ?? randomUUID(),
    tenant_id: '',
    object_name: 'invoice_line_item',
    object_type: 'invoice_line_item_default',
    status: 'active',
    version: 0,
    created_at: now(),
    updated_at: now(),
    data: {
      quantity: 1,
      price_at_time_of_invoice: 0,
      invoice_id: '',
      product_id: '',
      ...args.data
    }
  };
}

type AnyRecord = UserRecord | CustomerRecord | JobRecord | CalendarEventRecord | PricebookRecord | ProductRecord | LocationRecord | ProductItemRecord | PricebookEntryRecord | JobLineItemRecord | QuoteRecord | ObjectFeedRecord | InvoiceRecord | InvoiceLineItemRecord;

interface TestStep {
  device: string;
  actor: string;
  action: string;
}

interface ScenarioConfig {
  name?: string;
  description?: string;
  tenant: Partial<TenantData>;
  records: AnyRecord[];
  testScript?: TestStep[];
}

export function scenario(config: ScenarioConfig) {
  // Create tenant
  const tenantRecord = tenant({ data: config.tenant });

  // Inject tenant_id into all records
  const recordsWithTenant = config.records.map(record => ({
    ...record,
    tenant_id: tenantRecord.id
  }));

  return {
    name: config.name || 'Unnamed Scenario',
    description: config.description,
    tenant: tenantRecord,
    records: recordsWithTenant,
    testScript: config.testScript || []
  };
}
