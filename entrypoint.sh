#!/bin/bash
set -e

# Define defaults if not set via environment
: "${P4ROOT:=/opt/perforce/server}"
: "${P4PORT:=1666}"
: "${P4USER:=admin}"
: "${P4PASSWD:=changeme}"

# Ensure server root directory exists
if [ ! -d "$P4ROOT" ]; then
    mkdir -p "$P4ROOT"
fi

# Build p4d arguments
P4D_ARGS="-r $P4ROOT -p $P4PORT"

# Check if the core database file exists. If not, bootstrap the server.
if [ ! -f "$P4ROOT/db.domain" ]; then
    echo "=========================================="
    echo "First run detected. Initializing server..."
    echo "=========================================="

    # Case-insensitive mode (-C1) is only effective on a fresh database
    echo "Starting temporary server with case-insensitive mode (-C1)..."
    /opt/perforce/sbin/p4d $P4D_ARGS -C1 &
    P4D_PID=$!

    # Wait for the server to be ready (poll instead of a blind sleep)
    echo "Waiting for server to start..."
    for i in $(seq 1 20); do
        if p4 -p $P4PORT info >/dev/null 2>&1; then
            echo "Server is ready."
            break
        fi
        if [ "$i" -eq 30 ]; then
            echo "ERROR: Server did not start in time."
            exit 1
        fi
        sleep 5
    done

    # Create the superuser account
    echo "Creating superuser: $P4USER..."
    p4 -p $P4PORT -u "$P4USER" user -f -o | p4 -p $P4PORT -u "$P4USER" user -f -i

    # Set protections table — the first 'p4 protect' call makes the
    # calling user the superuser and gives all others 'write' access.
    echo "Setting protections table..."
    p4 -p $P4PORT -u "$P4USER" protect -o | p4 -p $P4PORT -u "$P4USER" protect -i

    # Set the password
    echo "Setting password for $P4USER..."
    p4 -p $P4PORT -u "$P4USER" passwd -P "$P4PASSWD"

    # Log in to get a ticket — required before further commands since
    # the server now expects authentication for this user.
    echo "$P4PASSWD" | p4 -p $P4PORT -u "$P4USER" login

    # Enforce passwords by setting security level 1
    #    Level 0 (default) does not require passwords at all.
    #    Level 1 requires all users to have passwords.
    echo "Setting server security level to 1..."
    p4 -p $P4PORT -u "$P4USER" configure set security=1

    # Shut down the temporary server cleanly
    echo "Initialization complete. Stopping temporary server..."
    kill -SIGTERM $P4D_PID
    wait $P4D_PID

    echo "=========================================="
    echo "Server initialized. User: $P4USER"
    echo "=========================================="
fi

# Normal startup: exec replaces the shell, making p4d PID 1 so it
# receives Docker signals cleanly
echo "Starting Perforce Server on port ${P4PORT}..."
exec /opt/perforce/sbin/p4d $P4D_ARGS
