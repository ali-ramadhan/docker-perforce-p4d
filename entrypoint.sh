#!/bin/bash
set -e

# Define P4ROOT and P4PORT if not set
: "${P4ROOT:=/opt/perforce/server}"
: "${P4PORT:=1666}"

# Ensure directory exists
if [ ! -d "$P4ROOT" ]; then
    mkdir -p "$P4ROOT"
fi

# Build p4d arguments
P4D_ARGS="-r $P4ROOT -p $P4PORT"

# Only enable case-insensitive mode (-C1) on first initialization.
# This flag is only effective when creating a new database; it is
# silently ignored on an existing server.
if [ ! -f "$P4ROOT/db.domain" ]; then
    echo "First run detected — initializing with case-insensitive mode (-C1)."
    P4D_ARGS="$P4D_ARGS -C1"
fi

# START SERVER
echo "Starting Perforce Server on port ${P4PORT}..."
exec /opt/perforce/sbin/p4d $P4D_ARGS
