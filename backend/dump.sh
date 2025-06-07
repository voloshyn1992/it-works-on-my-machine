#!/bin/bash

CONTAINER_NAME="postgres"
DUMP_FILE="db_schema.sql"

if [ ! -f "$DUMP_FILE" ]; then
    echo "File $DUMP_FILE not found!"
    exit 1
fi

if [ -f ".env.local" ]; then
    export $(grep -v '^#' .env.local | xargs)
else
    echo ".env.local file not found!"
    exit 1
fi

echo "Restoring database from $DUMP_FILE..."
cat $DUMP_FILE | docker exec -i $CONTAINER_NAME psql -U $DB_USER

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Database restored successfully!"
else
    echo "Failed to restore the database."
fi