#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE DATABASE test;
  CREATE DATABASE analytics;
EOSQL

for db in test analytics; do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname="$db" -f "/docker-entrypoint-initdb.d/${db}_schema.sql"
done