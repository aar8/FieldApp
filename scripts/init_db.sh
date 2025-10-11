#!/usr/bin/env bash
set -euo pipefail

DB_DIR="./sqlite-data"
DB_FILE="${DB_DIR}/fieldprime.db"
INIT_SQL="./server/init.sql"

echo "🧱 Initializing local SQLite database..."

# Ensure directories exist
mkdir -p "${DB_DIR}"

# Run the schema initialization
if ! command -v sqlite3 >/dev/null; then
  echo "❌ sqlite3 is not installed. Install it or run via Docker."
  exit 1
fi

if [ ! -f "${DB_FILE}" ]; then
  echo "📦 Creating new database at ${DB_FILE}"
  sqlite3 "${DB_FILE}" < "${INIT_SQL}"
else
  echo "🔄 Database already exists – running idempotent schema setup"
  # Run only statements that safely re-apply CREATE IF NOT EXISTS / CREATE INDEX IF NOT EXISTS
  sqlite3 "${DB_FILE}" < "${INIT_SQL}"
fi

# Fix ownership so Docker’s UID sqlite can write
echo "Fix ownership so Docker’s UID sqlite can write"
sudo chown -R :sqlite "${DB_DIR}"
sudo chmod -R g+rwX "${DB_DIR}"

echo "🎉 SQLite database initialized successfully!"