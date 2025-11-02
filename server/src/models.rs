// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

use serde::{Deserialize, Serialize};
use serde_json::Value;
use rusqlite::Row;


#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JobData {
    pub job_number: String,
    pub customer_id: String,
    pub job_address: Option<Address>,
    pub job_description: Option<String>,
    pub assigned_tech_id: Option<String>,
    pub status_note: Option<String>,
    pub quote_id: Option<String>,
    pub equipment_id: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JobRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: JobData,
}


  pub fn job_record_from_row(row: &Row) -> rusqlite::Result<JobRecord> {
      Ok(JobRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<JobData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct UserData {
    pub email: String,
    pub display_name: String,
    pub role: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct UserRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: UserData,
}


  pub fn user_record_from_row(row: &Row) -> rusqlite::Result<UserRecord> {
      Ok(UserRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<UserData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ContactInfo {
    pub email: Option<String>,
    pub phone: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Address {
    pub street: Option<String>,
    pub city: Option<String>,
    pub state: Option<String>,
    pub zip_code: Option<String>,
    pub country: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct CustomerData {
    pub name: String,
    pub contact: Option<ContactInfo>,
    pub address: Option<Address>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct CustomerRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: CustomerData,
}


  pub fn customer_record_from_row(row: &Row) -> rusqlite::Result<CustomerRecord> {
      Ok(CustomerRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<CustomerData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct CalendarEventData {
    pub title: String,
    pub start_time: String,
    pub end_time: String,
    pub is_all_day: Option<Value>,
    pub job_id: Option<String>,
    pub user_id: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct CalendarEventRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: CalendarEventData,
}


  pub fn calendar_event_record_from_row(row: &Row) -> rusqlite::Result<CalendarEventRecord> {
      Ok(CalendarEventRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<CalendarEventData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PricebookData {
    pub name: String,
    pub description: Option<String>,
    pub is_active: Option<Value>,
    pub currency: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PricebookRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: PricebookData,
}


  pub fn pricebook_record_from_row(row: &Row) -> rusqlite::Result<PricebookRecord> {
      Ok(PricebookRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<PricebookData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProductData {
    pub name: String,
    pub description: Option<String>,
    pub product_code: Option<String>,
    #[serde(rename = "type")]
    pub r#type: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProductRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: ProductData,
}


  pub fn product_record_from_row(row: &Row) -> rusqlite::Result<ProductRecord> {
      Ok(ProductRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<ProductData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LocationData {
    pub name: String,
    pub address: Option<Address>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LocationRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: LocationData,
}


  pub fn location_record_from_row(row: &Row) -> rusqlite::Result<LocationRecord> {
      Ok(LocationRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<LocationData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProductItemData {
    pub quantity_on_hand: f64,
    pub product_id: String,
    pub location_id: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ProductItemRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: ProductItemData,
}


  pub fn product_item_record_from_row(row: &Row) -> rusqlite::Result<ProductItemRecord> {
      Ok(ProductItemRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<ProductItemData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PricebookEntryData {
    pub price: f64,
    pub currency: String,
    pub pricebook_id: String,
    pub product_id: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PricebookEntryRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: PricebookEntryData,
}


  pub fn pricebook_entry_record_from_row(row: &Row) -> rusqlite::Result<PricebookEntryRecord> {
      Ok(PricebookEntryRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<PricebookEntryData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JobLineItemData {
    pub quantity: f64,
    pub price_at_time_of_sale: f64,
    pub description: Option<String>,
    pub job_id: String,
    pub product_id: String,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct JobLineItemRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: JobLineItemData,
}


  pub fn job_line_item_record_from_row(row: &Row) -> rusqlite::Result<JobLineItemRecord> {
      Ok(JobLineItemRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<JobLineItemData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct QuoteData {
    pub quote_number: String,
    pub customer_id: String,
    pub pricebook_id: Option<String>,
    pub total_amount: f64,
    pub currency: String,
    pub quote_status: Option<String>,
    pub notes: Option<String>,
    pub prepared_by: Option<String>,
    pub line_item_ids: Option<Vec<String>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct QuoteRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: QuoteData,
}


  pub fn quote_record_from_row(row: &Row) -> rusqlite::Result<QuoteRecord> {
      Ok(QuoteRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<QuoteData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ObjectFeedData {
    pub related_object_name: String,
    pub related_record_id: String,
    pub entry_type: Option<String>,
    pub message: Option<String>,
    pub author_id: Option<String>,
    pub attachment_ids: Option<Vec<String>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ObjectFeedRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: ObjectFeedData,
}


  pub fn object_feed_record_from_row(row: &Row) -> rusqlite::Result<ObjectFeedRecord> {
      Ok(ObjectFeedRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<ObjectFeedData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct InvoiceData {
    pub invoice_number: String,
    pub customer_id: String,
    pub job_id: Option<String>,
    pub quote_id: Option<String>,
    pub subtotal_amount: f64,
    pub tax_amount: Option<f64>,
    pub discount_amount: Option<f64>,
    pub total_amount: f64,
    pub currency: String,
    pub issue_date: String,
    pub due_date: Option<String>,
    pub payment_status: Option<String>,
    pub notes: Option<String>,
    pub issued_by: Option<String>,
    pub line_item_ids: Option<Vec<String>>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct InvoiceRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: InvoiceData,
}


  pub fn invoice_record_from_row(row: &Row) -> rusqlite::Result<InvoiceRecord> {
      Ok(InvoiceRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<InvoiceData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct InvoiceLineItemData {
    pub quantity: f64,
    pub price_at_time_of_invoice: f64,
    pub description: Option<String>,
    pub invoice_id: String,
    pub product_id: String,
    pub tax_rate: Option<f64>,
    pub discount_amount: Option<f64>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct InvoiceLineItemRecord {
    pub id: String,
    pub tenant_id: String,
    pub status: String,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
    pub object_name: String,
    pub object_type: String,
    pub data: InvoiceLineItemData,
}


  pub fn invoice_line_item_record_from_row(row: &Row) -> rusqlite::Result<InvoiceLineItemRecord> {
      Ok(InvoiceLineItemRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            status: row.get("status")?,
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<InvoiceLineItemData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct FieldDefinition {
    pub name: String,
    pub label: String,
    #[serde(rename = "type")]
    pub r#type: Option<String>,
    pub required: Option<Value>,
    pub format: Option<String>,
    pub options: Option<Vec<String>>,
    pub target_object: Option<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ObjectMetadataData {
    pub field_definitions: Vec<FieldDefinition>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct ObjectMetadataRecord {
    pub id: String,
    pub tenant_id: Option<String>,
    pub object_name: String,
    pub data: ObjectMetadataData,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}


  pub fn object_metadata_record_from_row(row: &Row) -> rusqlite::Result<ObjectMetadataRecord> {
      Ok(ObjectMetadataRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            object_name: row.get("object_name")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<ObjectMetadataData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LayoutSection {
    pub label: String,
    pub fields: Vec<String>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LayoutDefinitionData {
    pub sections: Vec<LayoutSection>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct LayoutDefinitionRecord {
    pub id: String,
    pub tenant_id: Option<String>,
    pub object_name: String,
    pub object_type: String,
    pub status: String,
    pub data: LayoutDefinitionData,
    pub version: f64,
    pub created_by: Option<String>,
    pub modified_by: Option<String>,
    pub created_at: String,
    pub updated_at: String,
}


  pub fn layout_definition_record_from_row(row: &Row) -> rusqlite::Result<LayoutDefinitionRecord> {
      Ok(LayoutDefinitionRecord {
            id: row.get("id")?,
            tenant_id: row.get("tenant_id")?,
            object_name: row.get("object_name")?,
            object_type: row.get("object_type")?,
            status: row.get("status")?,
            data: {
                let data_str: String = row.get("data")?;
                serde_json::from_str::<LayoutDefinitionData>(&data_str).map_err(|e| rusqlite::Error::FromSqlConversionFailure(0, rusqlite::types::Type::Text, Box::new(e)))?
            },
            version: row.get("version")?,
            created_by: row.get("created_by")?,
            modified_by: row.get("modified_by")?,
            created_at: row.get("created_at")?,
            updated_at: row.get("updated_at")?,
    })
  }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct SyncResponse {
    pub meta: Meta,
    pub data: ResponseData,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Meta {
    pub server_time: String,
    pub since: String,
}

#[derive(Serialize, Deserialize, Debug, Clone, Default)]
pub struct ResponseData {
    pub users: Vec<UserRecord>,
    pub customers: Vec<CustomerRecord>,
    pub jobs: Vec<JobRecord>,
    pub calendar_events: Vec<CalendarEventRecord>,
    pub pricebooks: Vec<PricebookRecord>,
    pub products: Vec<ProductRecord>,
    pub locations: Vec<LocationRecord>,
    pub product_items: Vec<ProductItemRecord>,
    pub pricebook_entries: Vec<PricebookEntryRecord>,
    pub job_line_items: Vec<JobLineItemRecord>,
    pub quotes: Vec<QuoteRecord>,
    pub object_feeds: Vec<ObjectFeedRecord>,
    pub invoices: Vec<InvoiceRecord>,
    pub invoice_line_items: Vec<InvoiceLineItemRecord>,
    pub object_metadata: Vec<ObjectMetadataRecord>,
    pub layout_definitions: Vec<LayoutDefinitionRecord>,
}