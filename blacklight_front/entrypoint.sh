#!/bin/bash
set -euo pipefail

echo "==> Waiting for PostgreSQL to be ready..."
MAX_RETRIES=30
RETRY_COUNT=0
until pg_isready -h "${DB_HOST:-postgres}" -p "${DB_PORT:-5432}" -U "${DB_USER:-swrails}" --timeout 2; do
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ "$RETRY_COUNT" -ge "$MAX_RETRIES" ]; then
    echo "ERROR: PostgreSQL not ready after $MAX_RETRIES attempts. Check DB_HOST, DB_PORT, DB_USER."
    exit 1
  fi
  echo "    PostgreSQL not ready yet — retrying in 2s... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 2
done
echo "==> PostgreSQL is ready."

echo "==> Running db:prepare..."
if ! bundle exec rails db:prepare; then
  echo "ERROR: db:prepare failed. Check database credentials and connectivity."
  exit 1
fi

echo "==> Preparing tmp directories..."
mkdir -p tmp/pids tmp/cache tmp/sockets

echo "==> Removing stale server PID if present..."
rm -f "${PIDFILE:-tmp/pids/server.pid}"

echo "==> Starting application..."
exec "$@"
