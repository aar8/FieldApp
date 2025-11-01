import { Project, InterfaceDeclaration, PropertySignature, SourceFile, Type } from 'ts-morph';
import { writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { parseTags } from './parseTags';

// --- Naming Convention Helpers ---
const toSnake = (name: string) => name.replace(/([A-Z])/g, '_$1').replace(/^_/, '').toLowerCase();
const toCamelFromSnake = (snake: string) => snake.replace(/_([a-z])/g, (_, c) => c.toUpperCase());

const pluralize = (w: string) => {
  const exceptions: Record<string, string> = { metadata: 'metadata', equipment: 'equipment' };
  if (exceptions[w]) return exceptions[w];
  if (/[^aeiou]y$/.test(w)) return w.slice(0, -1) + 'ies';
  if (/(s|x|z|ch|sh)$/.test(w)) return w + 'es';
  return w + 's';
};

const toTableName = (iface: string) => {
  const base = iface.replace(/Record$/, '');
  const snake = toSnake(base);
  const parts = snake.split('_');
  const last = parts.pop() || '';
  return [...parts, pluralize(last)].join('_');
};

// --- Data Structures ---
interface ResolvedProperty {
  name: string;
  type: Type; // Store the actual Type object from ts-morph
  isOptional: boolean;
  referenceTarget?: string;
  isSqlJson?: boolean;
}

interface ResolvedInterface {
  name: string;
  properties: ResolvedProperty[];
  inDb: boolean,
  inApi: boolean,
  platforms: {
    ios: boolean;
    server: boolean;
  };
}

// Extract per-property JSDoc tags like `@reference TargetRecord` and `@sqlJson`
function parsePropertyTags(prop: PropertySignature): { referenceTarget?: string; isSqlJson: boolean } {
  let referenceTarget: string | undefined;
  let isSqlJson = false;

  const tags = prop.getJsDocs().flatMap(d => d.getTags());
  for (const t of tags) {
    const anyTag = t as any;
    const raw = anyTag.getTagNameNode?.()?.getText?.() ?? t.getName();
    const comment = (anyTag.getCommentText?.() ?? t.getComment() ?? '').toString().trim();
    if (raw === 'reference') {
      referenceTarget = (comment.split(/\s+/)[0] || '').trim() || undefined;
    } else if (raw === 'sqlJson' || raw.toLowerCase() === 'sqljson') {
      isSqlJson = true;
    }
  }

  return { referenceTarget, isSqlJson };
}

// --- Phase 1: Resolution Logic ---
function resolveInterfaces(sourceFile: SourceFile): ResolvedInterface[] {
  const allInterfaces = sourceFile.getInterfaces();
  return allInterfaces.map(interfaceDecl => {

    const { inDb, inApi, platforms: platformNames } = parseTags(interfaceDecl);

    const tags = interfaceDecl.getJsDocs().flatMap(d => d.getTags());

    const properties: ResolvedProperty[] = [];

    const processProperties = (props: PropertySignature[]) => {
      props.forEach(prop => {
        const existingIndex = properties.findIndex(p => p.name === prop.getName());
        if (existingIndex !== -1) {
          properties.splice(existingIndex, 1);
        }
        const { referenceTarget, isSqlJson } = parsePropertyTags(prop);
        properties.push({
          name: prop.getName(),
          type: prop.getType(), // KEY CHANGE: Store the rich Type object
          isOptional: prop.hasQuestionToken(),
          referenceTarget,
          isSqlJson,
        });
      });
    };

    const heritageClauses = interfaceDecl.getHeritageClauses();
    let isRecord = false;
    if (heritageClauses.length > 0) {
      const baseInterfaceName = heritageClauses[0].getTypeNodes()[0].getText();
      const baseInterface = sourceFile.getInterface(baseInterfaceName);
      if (baseInterface) {
        isRecord = true;
        processProperties(baseInterface.getProperties());
      }
    }
    processProperties(interfaceDecl.getProperties());

    const platforms = {
        ios: !platformNames || platformNames.length === 0 || platformNames.includes('ios'),
        server: !platformNames || platformNames.length === 0 || platformNames.includes('server'),
    };

    console.log({ name: interfaceDecl.getName(), inDb,  inApi, platforms, properties })
    return {
      name: interfaceDecl.getName(),
      inDb,
      inApi,
      properties,
      platforms,
    };
  });
}

// --- Phase 2: Generation Logic ---
function generateSqlSchema(resolvedInterfaces: ResolvedInterface[]): string {
  console.log('\n--- Generating CREATE TABLE Statements ---');
  const statements: string[] = [];

  resolvedInterfaces.filter(intf => intf.platforms.server && intf.inDb).forEach(resolvedInterface => {
    const tableName = toTableName(resolvedInterface.name);
    const columns: string[] = [];

    resolvedInterface.properties.forEach(prop => {
      let columnDefinition = `  ${prop.name}`;
      const propType = prop.type;

      let sqlType = '';
      let constraints = '';

      // Prefer JSDoc tags over type branding
      if (prop.isSqlJson) {
        sqlType = 'JSON';
      } else if (prop.referenceTarget) {
        const referencedTable = toTableName(prop.referenceTarget);
        sqlType = 'TEXT';
        constraints = ` REFERENCES ${referencedTable}(id)`;
      } else if (propType.isStringLiteral()) {
        sqlType = 'TEXT';
        constraints = ` DEFAULT '${propType.getLiteralValue()}'`;
      } else if (propType.isString()) {
        sqlType = 'TEXT';
      } else if (propType.isNumber()) {
        sqlType = 'INTEGER';
      } else if (propType.isBoolean()) {
        sqlType = 'INTEGER';
      } else {
        const typeSymbol = propType.getAliasSymbol() || propType.getSymbol();
        const typeName = typeSymbol?.getName();
        sqlType = typeName || 'UNKNOWN';
      }

      columnDefinition += ` ${sqlType}`;

      if (prop.name === 'id') {
        columnDefinition += ' PRIMARY KEY';
      }

      if (!prop.isOptional) {
        columnDefinition += ' NOT NULL';
      }

      columnDefinition += constraints;

      if (!propType.isStringLiteral()) {
          if (prop.name === 'version' && !prop.isOptional) {
            columnDefinition += ' DEFAULT 0';
          }
          if (prop.name === 'created_at' && !prop.isOptional) {
            columnDefinition += ' DEFAULT (CURRENT_TIMESTAMP)';
          }
      }

      columns.push(columnDefinition);
    });

    const createTableStatement = `CREATE TABLE ${tableName} (\n${columns.join(',\n')}\n);`;
    statements.push(createTableStatement);
  });
  return statements.join('\n\n');
}

const getGenericTypeArg = (type: Type, expectedName?: string): Type | undefined => {
  // Unwrap unions like SqlJson<T> | undefined
  const base = type.isUnion()
    ? (type.getUnionTypes().find(u => !u.isUndefined() && !u.isNull()) ?? type)
    : type;

  // Optionally ensure we're on the expected generic (e.g., 'SqlJson' or 'Reference')
  const baseName = (base.getAliasSymbol() || base.getSymbol())?.getName();
  if (expectedName && baseName !== expectedName) return undefined;

  // Try regular generic args first
  const args = base.getTypeArguments();
  if (args.length > 0) return args[0];

  // Fallback for alias generics
  const aliasArgs = base.getAliasTypeArguments?.() ?? [];
  return aliasArgs.length > 0 ? aliasArgs[0] : undefined;
};

const getTypeName = (t: Type | undefined): string =>
  t ? ((t.getSymbol() || t.getAliasSymbol())?.getName() || t.getText()) : 'unknown';

function mapTsDataTypeToSwift(propType: Type, propName: string): string {
  const aliasOrSymbol = propType.getAliasSymbol() || propType.getSymbol();
  const typeName = aliasOrSymbol?.getName();

  if (propType.isArray()) {
    const elem = propType.getArrayElementTypeOrThrow();
    const mapped = mapTsDataTypeToSwift(elem, propName);
    return `[${mapped}]`;
  }

  if (typeName === 'Reference') {
    return 'String';
  }
  if (typeName === 'SqlJson') {
    const genericType = getGenericTypeArg(propType, 'SqlJson');
    return getTypeName(genericType);
  }
  if (propType.isStringLiteral() || propType.isString()) {
    return 'String';
  }
  if (propType.isNumber()) {
    return 'Double';
  }
  if (propType.isBoolean()) {
    return 'Bool';
  }

  // If it's an object/interface type, return its name if available
  const sym = propType.getSymbol();
  const name = sym?.getName();
  if (name) return name;

  // Fallback to String for unhandled cases (e.g., any)
  return 'String';
}

// Build a Swift UI model mapper property for a given Record interface
function generateRecordModelMapper(intf: ResolvedInterface): string {
  if (!intf.name.endsWith('Record')) return '';
  const dataProp = intf.properties.find(p => p.name === 'data');
  if (!dataProp) return '';
  const dataInner = dataProp.isSqlJson ? dataProp.type : undefined;
  if (!dataInner) return '';

  const modelName = intf.name.replace(/Record$/, '');
  const fields = dataInner.getProperties().map(sym => {
    const nm = sym.getName();
    const camel = toCamelFromSnake(nm);
    return `${camel}: data.${camel}`;
  });
  const args = ['id: id', ...fields].join(', ');
  return [
    `    var model: ${modelName} {`,
    `        ${modelName}(${args})`,
    `    }`,
  ].join('\n');
}

// --- Swift UI Models (Data + id) using resolvedInterfaces only ---
function generateSwiftModels(resolved: ResolvedInterface[]): string {
  const blocks: string[] = [];
  for (const intf of resolved) {
    if (!intf.name.endsWith('Record')) continue;
    const dataProp = intf.properties.find(p => p.name === 'data');
    if (!dataProp) continue;
    const dataInner = dataProp.isSqlJson ? dataProp.type : undefined;
    if (!dataInner) continue;

    // Derive fields from the inner data type without using sourceFile
    const modelFields = dataInner.getProperties().map(sym => {
      const decl: any = sym.getValueDeclaration?.() || (sym.getDeclarations?.() || [])[0];
      const name = sym.getName();
      const camel = toCamelFromSnake(name);
      const t = decl?.getType?.() || sym.getDeclaredType();
      const swiftType = mapTsDataTypeToSwift(t as Type, name);
      const optional = !!(decl?.hasQuestionToken?.());
      return { camel, swiftType, optional };
    });

    const modelName = intf.name.replace(/Record$/, '');
    const lines = [
      `struct ${modelName}: Identifiable, Hashable {`,
      `    let id: String`,
      ...modelFields.map(f => `    let ${f.camel}: ${f.swiftType}${f.optional ? '?' : ''}`),
      `}`,
    ];
    blocks.push(lines.join('\n'));
  }
  return blocks.join('\n\n');
}

// --- Swift Generation (SyncResponse wrappers) ---
function generateSwiftSyncResponse(sourceFile: SourceFile, resolvedInterfaces: ResolvedInterface[]): string {
  const header = `// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import Foundation
import GRDB
`;
  const dataStructs: string[] = [];

  for (const intf of resolvedInterfaces.filter(intf => intf.platforms.ios && (intf.inDb || intf.inApi))) {

    const props = intf.properties.map(p => {
      const name = p.name;
      const camel = toCamelFromSnake(name);
      const t = p.type;
      const swiftType = mapTsDataTypeToSwift(t, name);
      const optional = p.isOptional;
      return { name, camel, swiftType, optional };
    });

    const fieldLines = props.map(f => `    let ${f.camel}: ${f.swiftType}${f.optional ? '?' : ''}`);

    const codingKeyLines = props
      .filter(f => f.camel !== f.name)
      .map(f => `        case ${f.camel} = "${f.name}"`);
    const codingKeyLinesCombined = [
      ...codingKeyLines,
      ...props.filter(f => f.camel === f.name).map(f => `        case ${f.camel}`),
    ];
    const modelMapper = generateRecordModelMapper(intf);
    const block = [
      `struct ${intf.name}: Codable, Hashable${intf.inDb ? ', FetchableRecord, PersistableRecord' : ''} {`,
      ...fieldLines,
      intf.inDb ? `    static let databaseTableName = "${toTableName(intf.name)}"` : '',
      modelMapper,
      '',
      ...(codingKeyLinesCombined.length
        ? ['    enum CodingKeys: String, CodingKey {', ...codingKeyLinesCombined, '    }']
        : []),
      '}',
    ].filter(Boolean).join('\n');
    dataStructs.push(block);
  }

  const uiModels = generateSwiftModels(resolvedInterfaces);
  return [header, ...dataStructs, uiModels].join('\n\n');
}

// --- Swift GRDB Migrator Generation ---
function generateSwiftMigrator(resolvedInterfaces: ResolvedInterface[]): string {
  const header = `// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import Foundation
import GRDB
`;

  const stmts: string[] = [];

  const mapToGrdbType = (prop: ResolvedProperty): string => {
    if (prop.isSqlJson) return '.jsonText';
    if (prop.referenceTarget) return '.text';
    const t = prop.type;
    if (t.isStringLiteral() || t.isString()) return '.text';
    if (t.isNumber() || t.isBoolean()) return '.integer';
    return '.text';
  };

  for (const intf of resolvedInterfaces) {
    // Only generate tables for DB-included interfaces
    if (!intf.inDb) continue;
    const tableName = toTableName(intf.name);

    const cols: string[] = [];
    for (const prop of intf.properties) {
      if (prop.name === 'id') {
        cols.push(`t.primaryKey("id", .text)`);
        continue;
      }
      const grdbType = mapToGrdbType(prop);
      const notNull = prop.isOptional ? '' : '.notNull()';
      cols.push(`t.column("${prop.name}", ${grdbType})${notNull}`);
    }

    const createBlock = [
      `try db.create(table: "${tableName}") { t in`,
      ...cols.map(c => `    ${c}`),
      `}`,
    ].join('\n');

    stmts.push(createBlock);
  }

  const body = [
    'struct SchemaMigrator {',
    '    static func migrator() -> DatabaseMigrator {',
    '        var migrator = DatabaseMigrator()',
    '        migrator.registerMigration("v1") { db in',
    ...stmts.map(s => s.split('\n').map(l => '            ' + l).join('\n')),
    '        }',
    '        return migrator',
    '    }',
    '}',
  ].join('\n');

  return [header, body].join('\n');
}

// --- Metadata Generation ---
function generateDefaultMetadata(resolvedInterfaces: ResolvedInterface[]): string {
  const header = `// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import type { ObjectMetadataRecord } from '../../../plan/specs/schema';

export const defaultMetadata: ObjectMetadataRecord[] = [`;

  const records: string[] = [];

  for (const intf of resolvedInterfaces) {
    if (!intf.name.endsWith('Record')) continue;
    if (!intf.inApi) continue; // Only include API objects
    const dataProp = intf.properties.find(p => p.name === 'data');
    if (!dataProp || !dataProp.isSqlJson) continue;

    const objectName = toSnake(intf.name.replace(/Record$/, ''));
    const dataType = dataProp.type;

    const fieldDefs: string[] = [];
    for (const sym of dataType.getProperties()) {
      const decl: any = sym.getValueDeclaration?.() || (sym.getDeclarations?.() || [])[0];
      const fieldName = sym.getName();
      const fieldType = decl?.getType?.() || sym.getDeclaredType();
      const optional = !!(decl?.hasQuestionToken?.());

      // Parse JSDoc for @reference using existing parser
      const { referenceTarget } = decl ? parsePropertyTags(decl) : { referenceTarget: undefined }

      // Map TS type to metadata type
      let metaType = 'string';
      if (referenceTarget) {
        metaType = 'reference';
      } else if (fieldType.isNumber()) {
        metaType = 'numeric';
      } else if (fieldType.isBoolean()) {
        metaType = 'bool';
      } else if (fieldType.isUnion()) {
        // Check for string literal unions (picklist)
        const types = fieldType.getUnionTypes();
        const allStringLiterals = types.every(t => t.isStringLiteral() || t.isUndefined());
        if (allStringLiterals) {
          metaType = 'picklist';
        }
      }

      const label = fieldName.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');

      fieldDefs.push(`    { name: '${fieldName}', label: '${label}', type: '${metaType}', required: ${!optional}${referenceTarget ? `, target_object: '${toSnake(referenceTarget.replace(/Record$/, ''))}'` : ''} }`);
    }

    records.push(`  {
    id: 'metadata_${objectName}',
    object_name: '${objectName}',
    data: {
      field_definitions: [
${fieldDefs.join(',\n')}
      ]
    },
    version: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }`);
  }

  return header + '\n' + records.join(',\n') + '\n];\n';
}

// --- Layout Generation ---
function generateDefaultLayouts(resolvedInterfaces: ResolvedInterface[]): string {
  const header = `// GENERATED FILE — DO NOT EDIT
// Run: npm run build && npm run generate

import type { LayoutDefinitionRecord } from '../../../plan/specs/schema';

export const defaultLayouts: LayoutDefinitionRecord[] = [`;

  const records: string[] = [];

  for (const intf of resolvedInterfaces) {
    if (!intf.name.endsWith('Record')) continue;
    if (!intf.inApi) continue; // Only include API objects
    const dataProp = intf.properties.find(p => p.name === 'data');
    if (!dataProp || !dataProp.isSqlJson) continue;

    const objectName = toSnake(intf.name.replace(/Record$/, ''));
    const dataType = dataProp.type;

    const fields = dataType.getProperties().map(sym => sym.getName());

    records.push(`  {
    id: 'layout_${objectName}_default',
    object_name: '${objectName}',
    object_type: '*',
    status: '*',
    data: {
      sections: [
        { label: '${objectName.split('_').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')} Details', fields: ${JSON.stringify(fields)} }
      ]
    },
    version: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }`);
  }

  return header + '\n' + records.join(',\n') + '\n];\n';
}

function generateSwiftUpsertExtension(sourceFile: SourceFile): string {
  const header = `//
//  AppDatabase+Sync.generated.swift
//  FieldAppPrime
//
//  Created by Gemini on 10/30/25.
//
// This file is generated by the schema-codegen script. Do not edit manually.

import Foundation
import GRDB
`;

  const responseDataInterface = sourceFile.getInterface("ResponseData");
  if (!responseDataInterface) {
      return "// Error: Could not find ResponseData interface in schema.ts";
  }

  const properties = responseDataInterface.getProperties();
  const upsertLines = properties.map(prop => {
      const propName = prop.getName();
      const swiftPropName = toCamelFromSnake(propName);
      return `                try syncResponse.data.${swiftPropName}.forEach { try $0.save(db) }`;
  });

  const body = `
// This extension is generated to provide sync-related database operations.
extension AppDatabase {

    /**
     Performs an "upsert" (insert or update) for all records in a \`SyncResponse\`.
    
     This method iterates through all the record arrays in the \`SyncResponse.data\` payload
     and saves each record to the database within a single transaction. If any
     record fails to save, the entire transaction is rolled back.
    
     - Parameter syncResponse: The \`SyncResponse\` containing arrays of records to save.
     - Returns: A \`Result\` indicating success (\`.success\`) or failure (\`.failure(Error)\`).
     */
    func upsert(syncResponse: SyncResponse) -> Result<Void, Error> {
        do {
            try dbQueue.writeInTransaction { db in
${upsertLines.join('\n')}

                return .commit
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
}
`;
  return header + body;
}

// --- Main Orchestration ---
function main() {
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const SCHEMA_PATH = resolve(__dirname, '../../../plan/specs/schema.ts');

  console.log(`Reading schema from: ${SCHEMA_PATH}`);

  const project = new Project();
  project.addSourceFileAtPath(SCHEMA_PATH);

  const sourceFile = project.getSourceFileOrThrow(SCHEMA_PATH);

  const resolvedInterfaces = resolveInterfaces(sourceFile);
  const sql = generateSqlSchema(resolvedInterfaces);

  const OUTPUT_SQL = resolve(__dirname, '../../../server/init.generated.sql');
  const header = `-- GENERATED FILE — DO NOT EDIT
-- Run: npm run build && npm run generate
`;
  try {
    writeFileSync(OUTPUT_SQL, header + '\n' + sql + '\n');
    console.log(`
📝 Wrote SQL to: ${OUTPUT_SQL}`);
  } catch (err) {
    console.error('Failed to write SQL file:', err);
  }

  // Swift output (SyncResponse wrappers)
  const swift = generateSwiftSyncResponse(sourceFile, resolvedInterfaces);
  const OUTPUT_SWIFT = resolve(__dirname, '../../../mobile-ios/FieldAppPrime/FieldAppPrime/Models/SyncResponse.generated.swift');
  try {
    writeFileSync(OUTPUT_SWIFT, swift);
    console.log(`
📝 Wrote Swift to: ${OUTPUT_SWIFT}`);
  } catch (err) {
    console.error('Failed to write Swift file:', err);
  }

  // Swift GRDB migrator output
  const swiftMigrator = generateSwiftMigrator(resolvedInterfaces);
  const OUTPUT_MIGRATOR = resolve(__dirname, '../../../mobile-ios/FieldAppPrime/FieldAppPrime/Services/Persistence/SchemaMigrator.generated.swift');
  try {
    writeFileSync(OUTPUT_MIGRATOR, swiftMigrator);
    console.log(`
📝 Wrote Swift migrator to: ${OUTPUT_MIGRATOR}`);
  } catch (err) {
    console.error('Failed to write Swift migrator:', err);
  }

  // Metadata generation
  const metadata = generateDefaultMetadata(resolvedInterfaces);
  const OUTPUT_METADATA = resolve(__dirname, '../output/default-metadata.generated.ts');
  try {
    writeFileSync(OUTPUT_METADATA, metadata);
    console.log(`
📝 Wrote metadata to: ${OUTPUT_METADATA}`);
  } catch (err) {
    console.error('Failed to write metadata file:', err);
  }

  // Layout generation
  const layouts = generateDefaultLayouts(resolvedInterfaces);
  const OUTPUT_LAYOUTS = resolve(__dirname, '../output/default-layouts.generated.ts');
  try {
    writeFileSync(OUTPUT_LAYOUTS, layouts);
    console.log(`
📝 Wrote layouts to: ${OUTPUT_LAYOUTS}`);
  } catch (err) {
    console.error('Failed to write layouts file:', err);
  }

  // Swift Upsert extension output
  const swiftUpsert = generateSwiftUpsertExtension(sourceFile);
  const OUTPUT_UPSERT = resolve(__dirname, '../../../mobile-ios/FieldAppPrime/FieldAppPrime/Services/Persistence/AppDatabase+Sync.generated.swift');
  try {
    writeFileSync(OUTPUT_UPSERT, swiftUpsert);
    console.log(`\n📝 Wrote Swift upsert extension to: ${OUTPUT_UPSERT}`);
  } catch (err) {
    console.error('Failed to write Swift upsert extension file:', err);
  }

  console.log('\n✅ Generation complete.');
}

main();
