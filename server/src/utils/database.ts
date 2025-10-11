import Database, { type Database as SQLiteDatabase } from "better-sqlite3";
import { existsSync, mkdirSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";

const sqlitePath =
  process.env.SQLITE_PATH ??
  join(process.cwd(), "data", process.env.NODE_ENV === "test" ? "test.db" : "fieldprime.db");

const dataDir = dirname(sqlitePath);
if (!existsSync(dataDir)) {
  mkdirSync(dataDir, { recursive: true });
}

const database = new Database(sqlitePath);

database.pragma("journal_mode = WAL");
database.pragma("foreign_keys = ON");

const initSqlPath = join(process.cwd(), "init.sql");

export const bootstrapDatabase = (): void => {
  if (!existsSync(initSqlPath)) {
    throw new Error(`init.sql not found at ${initSqlPath}`);
  }

  const sql = readFileSync(initSqlPath, { encoding: "utf-8" });
  database.exec(sql);
};

export const withDatabase = async <T>(action: (db: SQLiteDatabase) => T): Promise<T> =>
  new Promise<T>((resolve, reject) => {
    setImmediate(() => {
      try {
        const result = action(database);
        resolve(result);
      } catch (error) {
        reject(error);
      }
    });
  });
