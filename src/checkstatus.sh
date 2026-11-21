#!/bin/sh
# Waits until the postgres service accepts connections.

HOST="${POSTGRES_HOST:-postgres}"
PORT="${POSTGRES_PORT:-5432}"

until pg_isready -h "$HOST" -p "$PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB"; do
  echo "Database is not ready yet, checking again in 2 seconds..."
  sleep 2
done

echo "The database is ready."