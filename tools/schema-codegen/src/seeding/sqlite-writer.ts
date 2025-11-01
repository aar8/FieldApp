import Database from 'better-sqlite3';
import { readFileSync } from 'fs';
import { fileURLToPath, pathToFileURL } from 'url';
import { resolve, dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

import type { TenantRecord, ObjectMetadataRecord, LayoutDefinitionRecord, UserRecord, CustomerRecord, JobRecord, CalendarEventRecord, PricebookRecord, ProductRecord, LocationRecord, ProductItemRecord, PricebookEntryRecord, JobLineItemRecord, QuoteRecord, ObjectFeedRecord, InvoiceRecord, InvoiceLineItemRecord } from '../../../../plan/specs/schema';

type AnyRecord = UserRecord | CustomerRecord | JobRecord | CalendarEventRecord | PricebookRecord | ProductRecord | LocationRecord | ProductItemRecord | PricebookEntryRecord | JobLineItemRecord | QuoteRecord | ObjectFeedRecord | InvoiceRecord | InvoiceLineItemRecord;

interface Scenario {
  name: string;
  description?: string;
  tenant: TenantRecord;
  records: AnyRecord[];
  testScript: TestStep[];
}

interface TestStep {
  device: string;
  actor: string;
  action: string;
}

function insertBaseRecord(db: Database.Database, tableName: string, record: AnyRecord) {
  const sql = `INSERT INTO ${tableName} (id, tenant_id, object_name, object_type, status, version, created_by, modified_by, created_at, updated_at, data)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  db.prepare(sql).run(
    record.id,
    record.tenant_id,
    record.object_name,
    record.object_type,
    record.status,
    record.version,
    record.created_by || null,
    record.modified_by || null,
    record.created_at,
    record.updated_at,
    JSON.stringify(record.data)
  );
}

function insertTenant(db: Database.Database, tenant: TenantRecord) {
  const sql = `INSERT INTO tenants (id, data, version, created_by, modified_by, created_at, updated_at)
               VALUES (?, ?, ?, ?, ?, ?, ?)`;

  db.prepare(sql).run(
    tenant.id,
    JSON.stringify(tenant.data),
    tenant.version,
    tenant.created_by || null,
    tenant.modified_by || null,
    tenant.created_at,
    tenant.updated_at
  );
}

function insertMetadataRecord(db: Database.Database, record: ObjectMetadataRecord) {
  const sql = `INSERT INTO object_metadata (id, tenant_id, object_name, data, version, created_by, modified_by, created_at, updated_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  db.prepare(sql).run(
    record.id,
    record.tenant_id || null,
    record.object_name,
    JSON.stringify(record.data),
    record.version,
    record.created_by || null,
    record.modified_by || null,
    record.created_at,
    record.updated_at
  );
}

function insertLayoutRecord(db: Database.Database, record: LayoutDefinitionRecord) {
  const sql = `INSERT INTO layout_definitions (id, tenant_id, object_name, object_type, status, data, version, created_by, modified_by, created_at, updated_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;

  db.prepare(sql).run(
    record.id,
    record.tenant_id || null,
    record.object_name,
    record.object_type,
    record.status,
    JSON.stringify(record.data),
    record.version,
    record.created_by || null,
    record.modified_by || null,
    record.created_at,
    record.updated_at
  );
}

function toTableName(objectName: string): string {
  const pluralize = (w: string) => {
    if (w === 'metadata') return 'metadata';
    if (/[^aeiou]y$/.test(w)) return w.slice(0, -1) + 'ies';
    if (/(s|x|z|ch|sh)$/.test(w)) return w + 'es';
    return w + 's';
  };

  const parts = objectName.split('_');
  const last = parts.pop() || '';
  return [...parts, pluralize(last)].join('_');
}

function printTestScript(testScript: TestStep[]) {
  if (testScript.length === 0) return;

  console.log('\n📋 TEST SCRIPT:');
  testScript.forEach((step, i) => {
    console.log(`${i + 1}. [${step.device} - ${step.actor}] ${step.action}`);
  });
  console.log();
}

export async function seedDatabase(dbPath: string, scenario: Scenario) {
  const db = new Database(dbPath);

  try {
    // 1. Drop all tables
    const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all() as { name: string }[];
    for (const table of tables) {
      if (table.name !== 'sqlite_sequence') {
        db.prepare(`DROP TABLE IF EXISTS ${table.name}`).run();
      }
    }

    // 2. Run init.generated.sql to recreate schema
    const initSqlPath = resolve(__dirname, '../../../../server/init.generated.sql');
    const initSql = readFileSync(initSqlPath, 'utf8');
    db.exec(initSql);

    // 3. Insert metadata records
    const metadataModule = await import('../../output/default-metadata.generated.js');
    for (const record of metadataModule.defaultMetadata) {
      insertMetadataRecord(db, record);
    }

    // 4. Insert layout records
    const layoutsModule = await import('../../output/default-layouts.generated.js');
    for (const record of layoutsModule.defaultLayouts) {
      insertLayoutRecord(db, record);
    }

    // 5. Insert tenant
    insertTenant(db, scenario.tenant);

    // 6. Insert scenario records
    for (const record of scenario.records) {
      const tableName = toTableName(record.object_name);
      insertBaseRecord(db, tableName, record);
    }

    console.log(`✅ Seeded database: ${dbPath}`);
    console.log(`   Tenant: ${scenario.tenant.data.name}`);
    console.log(`   Records: ${scenario.records.length}`);

    // 7. Print test script
    printTestScript(scenario.testScript);

  } finally {
    db.close();
  }
}