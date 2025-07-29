#!/bin/bash
set -e

# Start SSH
echo "Starting SSH..."
service ssh start

# Start PostgreSQL
echo "Starting PostgreSQL..."
su postgres -c "/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/17/main -o '-c config_file=/etc/postgresql/17/main/postgresql.conf' -l /var/log/postgresql/postgresql-17-main.log start"

# Copy SSL certificate to accessible location for Windows clients
echo "Copying SSL certificate to /tmp/certs..."
mkdir -p /tmp/certs
cp /var/lib/postgresql/17/main/ssl/server.crt /tmp/certs/ 2>/dev/null || echo "Certificate copy failed, certificate might already exist in /tmp/"
chmod 644 /tmp/certs/server.crt 2>/dev/null || true
cp /var/lib/postgresql/17/main/ssl/client.crt /tmp/certs/ 2>/dev/null || echo "Certificate copy failed, certificate might already exist in /tmp/"
chmod 644 /tmp/certs/client.crt 2>/dev/null || true
cp /var/lib/postgresql/17/main/ssl/client.key /tmp/certs/ 2>/dev/null || echo "Key copy failed, key might already exist in /tmp/"
chmod 644 /tmp/certs/client.key 2>/dev/null || true
cp /var/lib/postgresql/17/main/ssl/root.crt /tmp/certs/ 2>/dev/null || echo "Certificate copy failed, certificate might already exist in /tmp/"
chmod 644 /tmp/certs/root.crt 2>/dev/null || true

# Check PostgreSQL status and log
if ! su postgres -c "/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/17/main status"; then
    echo "PostgreSQL failed to start. Showing last 20 lines of log:"
    tail -n 20 /var/log/postgresql/postgresql-17-main.log
fi

# Function to stop services gracefully
stop_services() {
    echo "Stopping services..."
    su postgres -c "/usr/lib/postgresql/17/bin/pg_ctl -D /var/lib/postgresql/17/main stop"
    service ssh stop
    exit 0
}

# Trap SIGTERM and SIGINT
trap stop_services SIGTERM SIGINT

# Keep the script running
echo "Services started, waiting for signals..."
while true; do
    sleep 1
done