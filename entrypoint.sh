#!/bin/sh

set -e

echo "Waiting for PostgreSQL at ${DB_HOSTNAME}:${DB_PORT}..."

timeout=60
elapsed=0

while ! nc -z "$DB_HOSTNAME" "$DB_PORT"; do
    if [ "$elapsed" -ge "$timeout" ]; then
        echo "ERROR: PostgreSQL was not reachable within ${timeout} seconds."
        exit 1
    fi

    sleep 1
    elapsed=$((elapsed + 1))
done

echo "PostgreSQL is reachable."

exec "$@"
