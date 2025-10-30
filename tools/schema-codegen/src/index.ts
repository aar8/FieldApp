import { Project, InterfaceDeclaration, PropertySignature, SourceFile, Type } from 'ts-morph';
import { writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { parseTags } from './parseTags';

// --- Data Structures ---
interface ResolvedProperty {
  name: string;
  type: Type; // Store the actual Type object from ts-morph
  isOptional: boolean;
}

interface ResolvedInterface {
  name: string;
  properties: ResolvedProperty[];
  inDb: boolean,
  inApi: boolean
}

function toTableName(name: string): string {
  const base = name.replace(/Record$/, '');
  const snake = base.replace(/([A-Z])/g, '_$1').replace(/^_/, '').toLowerCase();

  const parts = snake.split('_');
  const last = parts.pop() || '';

  const exceptions: Record<string, string> = {
    metadata: 'metadata',
    equipment: 'equipment',
  };

  const pluralize = (w: string): string => {
    if (exceptions[w]) return exceptions[w];
    if (/[^aeiou]y$/.test(w)) return w.slice(0, -1) + 'ies';
    if (/(s|x|z|ch|sh)$/.test(w)) return w + 'es';
    return w + 's';
  };

  const pluralLast = pluralize(last);
  return [...parts, pluralLast].join('_');
}

// --- Phase 1: Resolution Logic ---
function resolveInterfaces(sourceFile: SourceFile, targetNames: string[]): ResolvedInterface[] {
  const allInterfaces = sourceFile.getInterfaces();
  // const targetInterfaces = allInterfaces.filter(i => targetNames.includes(i.getName()));

  // console.log(`\nFound ${targetInterfaces.length} of ${targetNames.length} targeted interfaces.`);
  return allInterfaces.map(interfaceDecl => {

    const { inDb, inApi } = parseTags(interfaceDecl);

    const tags = interfaceDecl.getJsDocs().flatMap(d => d.getTags());

    // const tags = i.map(t => t.getTagNameNode()?.getText());
    // console.log(tags)
    const properties: ResolvedProperty[] = [];

    const processProperties = (props: PropertySignature[]) => {
      props.forEach(prop => {
        const existingIndex = properties.findIndex(p => p.name === prop.getName());
        if (existingIndex !== -1) {
          properties.splice(existingIndex, 1);
        }
        properties.push({
          name: prop.getName(),
          type: prop.getType(), // KEY CHANGE: Store the rich Type object
          isOptional: prop.hasQuestionToken(),
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

    console.log({ name: interfaceDecl.getName(), inDb,  inApi, properties })
    return {
      name: interfaceDecl.getName(),
      inDb, 
      inApi,
      properties,
    };
  });
}

// --- Phase 2: Generation Logic ---
function generateSqlSchema(resolvedInterfaces: ResolvedInterface[]): string {
  console.log('\n--- Generating CREATE TABLE Statements ---');
  const statements: string[] = [];

  // Local helper to convert a Record interface name to a table name


  resolvedInterfaces.filter(intf => intf.inDb).forEach(resolvedInterface => {
    const tableName = toTableName(resolvedInterface.name);
    const columns: string[] = [];

    resolvedInterface.properties.forEach(prop => {
      let columnDefinition = `  ${prop.name}`;
      const propType = prop.type;

      let sqlType = '';
      let constraints = '';

      // Get the symbol for the type, which could be an alias
      const typeSymbol = propType.getAliasSymbol() || propType.getSymbol();
      const typeName = typeSymbol?.getName();

      if (typeName === 'SqlJson') {
        sqlType = 'JSON';
      } else if (typeName === 'Reference') {
        const referencedRecord = propType.getTypeArguments()[0].getSymbol()?.getName() || 'unknown';
        const referencedTable = toTableName(referencedRecord);
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
    // console.log('\n' + createTableStatement);
    statements.push(createTableStatement);
  });
  return statements.join('\n\n');
}

// // --- Swift helpers ---
// function mapTsTypeToSwiftForBaseRecord(propType: Type, propName: string): string {
//   const aliasOrSymbol = propType.getAliasSymbol() || propType.getSymbol();
//   const typeName = aliasOrSymbol?.getName();

//   if (typeName === 'Reference') {
//     return 'String';
//   }
//   if (typeName === 'SqlJson') {
//     return propName === 'data' ? 'T' : 'String';
//   }
//   if (propType.isStringLiteral() || propType.isString()) {
//     return 'String';
//   }
//   if (propType.isNumber()) {
//     return 'Int';
//   }
//   if (propType.isBoolean()) {
//     return 'Bool';
//   }
//   return 'String';
// }

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

const toSnake = (name: string) => name.replace(/([A-Z])/g, '_$1').replace(/^_/, '').toLowerCase();
const pluralize = (w: string) => {
  const exceptions: Record<string, string> = { metadata: 'metadata', equipment: 'equipment' };
  if (exceptions[w]) return exceptions[w];
  if (/[^aeiou]y$/.test(w)) return w.slice(0, -1) + 'ies';
  if (/(s|x|z|ch|sh)$/.test(w)) return w + 'es';
  return w + 's';
};

const toTable = (iface: string) => {
  const base = iface.replace(/Record$/, '');
  const snake = toSnake(base);
  const parts = snake.split('_');
  const last = parts.pop() || '';
  return [...parts, pluralize(last)].join('_');
};
const toCamelFromSnake = (snake: string) => snake.replace(/_([a-z])/g, (_, c) => c.toUpperCase());

// Build a Swift UI model mapper property for a given Record interface
function generateRecordModelMapper(intf: ResolvedInterface): string {
  if (!intf.name.endsWith('Record')) return '';
  const dataProp = intf.properties.find(p => p.name === 'data');
  if (!dataProp) return '';
  const dataInner = getGenericTypeArg(dataProp.type, 'SqlJson');
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
    const dataInner = getGenericTypeArg(dataProp.type, 'SqlJson');
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
  // Helpers mirroring table naming

  /*
  const interfaces = sourceFile.getInterfaces();
  // Collect BaseRecord fields for APIRecord generation
  const baseRecord = sourceFile.getInterface('BaseRecord');
  const baseFields = baseRecord
    ? baseRecord.getProperties().map(p => {
        const name = p.getName();
        const t = p.getType();
        const swiftType = mapTsTypeToSwiftForBaseRecord(t, name);
        const optional = p.hasQuestionToken();
        const camel = toCamelFromSnake(name);
        return { name, camel, swiftType, optional };
      })
    : [];
  const adherents = interfaces.filter(i =>
    i.getName().endsWith('Record') &&
    i.getHeritageClauses().some(h => h.getTypeNodes().some(t => t.getText().replace(/\s/g, '') === 'BaseRecord'))
  );

  const items = adherents.map(i => {
    const dataProp = i.getProperty('data');
    const dataArg = dataProp?.getType().getTypeArguments()[0];
    const dataTypeName = dataArg?.getSymbol()?.getName() || 'UnknownData';
    const tableName = toTable(i.getName());
    const propName = toCamelFromSnake(tableName);
    return { propName, tableName, dataTypeName };
  }).sort((a, b) => a.tableName.localeCompare(b.tableName));

  // Build APIRecord<T> from BaseRecord fields
  const fieldLines = baseFields.map(f => `    let ${f.camel}: ${f.swiftType}${f.optional ? '?' : ''}`);
  const codingKeyLines = baseFields
    .filter(f => f.camel !== f.name)
    .map(f => `        case ${f.camel} = "${f.name}"`);
    
  const codingKeyLinesCombined = [
    ...codingKeyLines,
    ...baseFields.filter(f => f.camel === f.name).map(f => `        case ${f.camel}`),
  ];
*/  
  const header = `// GENERATED FILE — DO NOT EDIT\n// Run: npm run build && npm run generate\n\nimport Foundation\nimport GRDB\n`;
/*
  const apiRecord = [
    'struct APIRecord<T: Codable>: Codable {',
    ...fieldLines,
    '',
    '    enum CodingKeys: String, CodingKey {',
    ...codingKeyLinesCombined,
    '    }',
    '}',
  ].join('\n');

  // Build DataPayload from adherent BaseRecord subtypes
  const payloadProps = items.map(it => `    let ${it.propName}: [APIRecord<${it.dataTypeName}>]`).join('\n');
  const payloadKeys = [
    '    enum CodingKeys: String, CodingKey {',
    ...items.map(it => `        case ${it.propName} = "${it.tableName}"`),
    '    }',
  ].join('\n');
  const dataPayload = [
    'struct DataPayload: Decodable {',
    payloadProps,
    '',
    payloadKeys,
    '}',
  ].join('\n');

  const syncStruct = [
    'struct SyncResponse: Decodable {',
    '    let meta: Meta',
    '    let data: DataPayload',
    '}',
  ].join('\n');

  const metaStruct = [
    'struct Meta: Decodable {',
    '    let serverTime: Date',
    '    let since: String',
    '',
    '    enum CodingKeys: String, CodingKey {',
    '        case serverTime = "server_time"',
    '        case since',
    '    }',
    '}',
  ].join('\n');
*/

  // Generate Swift structs for all interfaces that are NOT BaseRecord or descendants of BaseRecord
  // const allIfaces = sourceFile.getInterfaces();
  // const isDescendantOfBase = (iface: InterfaceDeclaration): boolean =>
  //   iface.getHeritageClauses().some(h => h.getTypeNodes().some(t => t.getText().replace(/\s/g, '') === 'BaseRecord'));
  // const dataTypeNames = allIfaces
  //   .filter(i => i.getName() !== 'BaseRecord' && !isDescendantOfBase(i))
  //   .map(i => i.getName())
  //   .sort();
  const dataStructs: string[] = [];

  for (const intf of resolvedInterfaces.filter(intf => intf.inDb || intf.inApi)) {
    // const intf = sourceFile.getInterface(dtName);
    // if (!intf) continue;

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
      intf.inDb ? `    static let databaseTableName = "${toTable(intf.name)}"` : '',
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
  return [header, /*apiRecord, syncStruct, metaStruct, dataPayload,*/ ...dataStructs, uiModels].join('\n\n');
}

// --- Swift GRDB Migrator Generation ---
function generateSwiftMigrator(resolvedInterfaces: ResolvedInterface[]): string {
  const header = `// GENERATED FILE — DO NOT EDIT\n// Run: npm run build && npm run generate\n\nimport Foundation\nimport GRDB\n`;

  const stmts: string[] = [];

  const mapToGrdbType = (t: Type): string => {
    const typeSymbol = t.getAliasSymbol() || t.getSymbol();
    const typeName = typeSymbol?.getName();
    if (typeName === 'SqlJson') return '.jsonText';
    if (typeName === 'Reference') return '.text';
    if (t.isStringLiteral() || t.isString()) return '.text';
    if (t.isNumber() || t.isBoolean()) return '.integer';
    return '.text';
  };

  for (const intf of resolvedInterfaces) {
    // Only generate tables for DB-included interfaces
    if (!intf.inDb) continue;
    const tableName = toTable(intf.name);

    const cols: string[] = [];
    for (const prop of intf.properties) {
      if (prop.name === 'id') {
        cols.push(`t.primaryKey("id", .text)`);
        continue;
      }
      const grdbType = mapToGrdbType(prop.type);
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

  return [header, body].join('\n\n');
}

// --- Main Orchestration ---
function main() {
  const __dirname = dirname(fileURLToPath(import.meta.url));
  const SCHEMA_PATH = resolve(__dirname, '../../../plan/specs/schema.ts');
  const targetNames = ['JobRecord', 'ObjectMetadataRecord'];

  console.log(`Reading schema from: ${SCHEMA_PATH}`);
  console.log(`Targeting ${targetNames.length} interfaces: ${targetNames.join(', ')}`);

  const project = new Project();
  project.addSourceFileAtPath(SCHEMA_PATH);

  const sourceFile = project.getSourceFileOrThrow(SCHEMA_PATH);

  const resolvedInterfaces = resolveInterfaces(sourceFile, targetNames);
  const sql = generateSqlSchema(resolvedInterfaces);

  const OUTPUT_SQL = resolve(__dirname, '../../../server/init.generated.sql');
  const header = `-- GENERATED FILE — DO NOT EDIT\n-- Run: npm run build && npm run generate\n`;
  try {
    writeFileSync(OUTPUT_SQL, header + '\n' + sql + '\n');
    console.log(`\n📝 Wrote SQL to: ${OUTPUT_SQL}`);
  } catch (err) {
    console.error('Failed to write SQL file:', err);
  }

  // Swift output (SyncResponse wrappers)
  const swift = generateSwiftSyncResponse(sourceFile, resolvedInterfaces);
  const OUTPUT_SWIFT = resolve(__dirname, '../../../mobile-ios/FieldAppPrime/FieldAppPrime/Models/SyncResponse.generated.swift');
  try {
    writeFileSync(OUTPUT_SWIFT, swift);
    console.log(`\n📝 Wrote Swift to: ${OUTPUT_SWIFT}`);
  } catch (err) {
    console.error('Failed to write Swift file:', err);
  }

  // Swift GRDB migrator output
  const swiftMigrator = generateSwiftMigrator(resolvedInterfaces);
  const OUTPUT_MIGRATOR = resolve(__dirname, '../../../mobile-ios/FieldAppPrime/FieldAppPrime/Services/Persistence/SchemaMigrator.generated.swift');
  try {
    writeFileSync(OUTPUT_MIGRATOR, swiftMigrator);
    console.log(`\n📝 Wrote Swift migrator to: ${OUTPUT_MIGRATOR}`);
  } catch (err) {
    console.error('Failed to write Swift migrator:', err);
  }

  console.log('\n✅ Generation complete.');
}

main();
