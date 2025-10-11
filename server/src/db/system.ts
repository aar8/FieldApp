import type { Database } from "better-sqlite3";

export const checkDatabase = (db: Database): boolean => {
  const row = db.prepare("SELECT 1 as ok").get() as { ok?: number } | undefined;
  return row?.ok === 1;
};
