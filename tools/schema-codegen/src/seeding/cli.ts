import { seedDatabase } from './sqlite-writer.js';
import { resolve, dirname } from 'path';
import { fileURLToPath, pathToFileURL } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function main() {
  const scenarioFile = process.argv[2];

  if (!scenarioFile) {
    console.error('Usage: npm run seed <scenario-file>');
    process.exit(1);
  }

  const scenarioPath = resolve(process.cwd(), scenarioFile);
  const scenarioModule = await import(pathToFileURL(scenarioPath).href);
  const scenario = scenarioModule.default;

  const dbPath = resolve(__dirname, '../../../../sqlite-data/fieldprime.db');

  console.log(`📦 Seeding scenario: ${scenario.name}`);
  await seedDatabase(dbPath, scenario);
}

main().catch(err => {
  console.error('Seeding failed:', err);
  process.exit(1);
});