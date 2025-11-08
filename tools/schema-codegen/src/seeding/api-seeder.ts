
import { randomUUID } from 'crypto';
import { createHash } from 'crypto';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import type { JobRecord } from '../../../../plan/specs/schema';

// --- Configuration ---
let API_BASE_URL = process.env.API_BASE_URL || 'http://localhost:8080';
const GENESIS_HASH = '0000000000000000000000000000000000000000000000000000000000000000';

// --- Types ---
// We use JSON Merge Patch semantics on the server (SQLite json_patch),
// so `changes` should be a JSON object of fields to merge into the `data` column.
type JsonMergePatch = Record<string, any>;

interface OverlayRecord {
  id: string;
  tenant_id: string;
  object_id: string;
  object_name: string;
  changes: JsonMergePatch;
  created_at: string;
  state_hash: string;
  previous_state_hash: string;
}

// --- Hashing Logic ---

/**
 * Creates a SHA256 hash of the input string.
 */
function sha256(input: string): string {
  return createHash('sha256').update(input).digest('hex');
}

/**
 * Calculates the next state_hash based on the server's logic.
 */
function calculateNextStateHash(
  partialOverlay: Omit<OverlayRecord, 'state_hash' | 'previous_state_hash'>,
  previous_state_hash: string,
  userId: string
): string {
  // Canonicalize the JSON patch by minifying it.
  const changes_json = JSON.stringify(partialOverlay.changes);

  // 1. Create the content hash, matching the server's implementation.
  const change_to_hash =
    partialOverlay.id +
    partialOverlay.tenant_id +
    userId +
    partialOverlay.created_at +
    partialOverlay.object_name +
    partialOverlay.object_id +
    changes_json;
  
  const change_hash = sha256(change_to_hash);

  // 2. Combine with the previous hash to create the new state hash.
  const combined_hash_data = change_hash + previous_state_hash;
  const server_calculated_hash = sha256(combined_hash_data);

  return server_calculated_hash;
}

/**
 * Transforms a record's data object into a JSON patch for creation.
 * This assumes creation from an empty '{}' object.
 */
function createCreationPatch(data: Record<string, any>): JsonMergePatch {
  // For a create, send the full initial document as a merge patch.
  // The server applies: data = json_patch(data, changes)
  return data;
}


// --- Main Seeding Logic ---

/**
 * Constructs a chain of overlay records from seed data.
 */
function buildOverlayChain(
  tenantId: string,
  userId: string,
  records: JobRecord[]
): OverlayRecord[] {
  let currentHead = GENESIS_HASH;
  const overlays: OverlayRecord[] = [];

  for (const record of records) {
    const now = new Date().toISOString();
    const changes = createCreationPatch(record.data);

    const partialOverlay: Omit<OverlayRecord, 'state_hash' | 'previous_state_hash'> = {
      id: randomUUID(),
      tenant_id: tenantId,
      object_id: record.id,
      object_name: record.object_name,
      changes: changes,
      created_at: now,
    };

    const state_hash = calculateNextStateHash(partialOverlay, currentHead, userId);

    const completeOverlay: OverlayRecord = {
      ...partialOverlay,
      state_hash,
      previous_state_hash: currentHead,
    };

    overlays.push(completeOverlay);
    currentHead = state_hash; // The new becomes the previous for the next iteration
  }

  return overlays;
}

/**
 * Pushes a batch of overlay records to the sync endpoint.
 */
async function pushOverlays(
  overlays: OverlayRecord[],
  userId: string
): Promise<void> {
  if (overlays.length === 0) {
    console.log('No overlays to push.');
    return;
  }

  const tenantId = overlays[0]?.tenant_id;
  console.log(`📦 Pushing ${overlays.length} changes for tenant ${tenantId} to ${API_BASE_URL}/sync ...`);

  try {
    const response = await fetch(`${API_BASE_URL}/sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-User-ID': userId,
      },
      body: JSON.stringify(overlays),
    });

    if (response.ok) {
      const result = await response.json();
      console.log(`✅ Sync push successful for tenant ${tenantId}:`, result);
    } else {
      const errorBody = await response.text();
      console.error(`❌ Sync push failed for tenant ${tenantId} with status ${response.status}:`);
      console.error(errorBody);
      throw new Error(`HTTP ${response.status}`);
    }
  } catch (error) {
    console.error('An error occurred during the fetch operation:', error);
    throw error;
  }
}

/**
 * Main function to seed a tenant with data via the API.
 */
export async function seedTenantViaApi(
  tenantId: string,
  userId: string,
  records: JobRecord[]
) {
  console.log(`🌱 Starting API seeding for tenant ${tenantId}...`);
  
  // 1. Build the chain of changes
  const overlayChain = buildOverlayChain(tenantId, userId, records);
  
  // 2. Push the changes to the server
  await pushOverlays(overlayChain, userId);

  console.log('🎉 API seeding complete.');
}

// If invoked directly (e.g., with `tsx src/seeding/api-seeder.ts`),
// send a small sample batch to the running server.
if (import.meta.url === (process?.argv?.[1] ? new URL('file://' + process.argv[1]).href : '')) {
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = dirname(__filename);

  // Simple fixed config: tools/schema-codegen/src/seeding/seed.config.json
  const defaultConfigPath = resolve(__dirname, './seed.config.json');
  const explicitPath = process.argv[2] ? resolve(process.cwd(), process.argv[2]) : undefined;
  const configPath = explicitPath && existsSync(explicitPath) ? explicitPath : defaultConfigPath;

  try {
    const raw = readFileSync(configPath, 'utf8');
    const cfg = JSON.parse(raw) as { apiBaseUrl: string; tenantId: string; userId?: string };
    if (!cfg.apiBaseUrl || !cfg.tenantId) {
      console.error(`seed.config missing required fields. Expected { apiBaseUrl, tenantId, userId? } at ${configPath}`);
      process.exit(1);
    }
    API_BASE_URL = cfg.apiBaseUrl;
    var tenantId = cfg.tenantId;
    var userId = cfg.userId || 'api-seeder';
    console.log(`Using config ${configPath} (tenantId=${tenantId}, apiBaseUrl=${API_BASE_URL})`);
  } catch (e) {
    console.error(`Failed to read seed config at ${configPath}. Pass a path or create seed.config.json.`);
    process.exit(1);
  }

  // Minimal sample jobs. Only `id`, `object_name`, and `data` are used by this seeder.
  const sampleJobs: JobRecord[] = [
    {
      id: randomUUID(),
      tenant_id: tenantId,
      status: 'new',
      version: 0,
      created_by: userId,
      modified_by: userId,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      object_name: 'job',
      object_type: 'job_generic',
      data: {
        customer_id: 'cust-1',
        job_description: 'Install smart thermostat',
        job_number: 'J-1001',
        status_note: 'created via api-seeder',
      },
    } as unknown as JobRecord,
    {
      id: randomUUID(),
      tenant_id: tenantId,
      status: 'new',
      version: 0,
      created_by: userId,
      modified_by: userId,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
      object_name: 'job',
      object_type: 'job_generic',
      data: {
        customer_id: 'cust-2',
        job_description: 'AC tune-up',
        job_number: 'J-1002',
        status_note: 'created via api-seeder',
      },
    } as unknown as JobRecord,
  ];

  seedTenantViaApi(tenantId, userId, sampleJobs)
    .then(() => {
      console.log('Done.');
    })
    .catch((err) => {
      console.error(err);
      process.exit(1);
    });
}
