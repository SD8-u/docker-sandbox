#!/bin/bash
set -e

# Update and install necessary packages
apt-get update
apt-get install -y wget gnupg lsb-release openssh-server nano less

# Set up PostgreSQL repository
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Update package list and install PostgreSQL 17 and NFS
apt-get update
apt-get install -y postgresql-17 nfs-kernel-server nfs-common

# Configure SSH
mkdir -p /var/run/sshd
echo 'root:changeme' | chpasswd
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Configure PostgreSQL
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/#log_destination = 'stderr'/log_destination = 'csvlog'/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/#logging_collector = off/logging_collector = on/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/#track_io_timing = off/track_io_timing = on/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/#shared_preload_libraries = ''/shared_preload_libraries = 'pg_stat_statements, auto_explain'/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/local   all             postgres                                peer/local   all             postgres                                trust/" /etc/postgresql/17/main/pg_hba.conf
echo "host    all             all             0.0.0.0/0               scram-sha-256" >> /etc/postgresql/17/main/pg_hba.conf
echo "host    all             all             ::/0                    scram-sha-256" >> /etc/postgresql/17/main/pg_hba.conf

# Configure auto_explain
echo "
auto_explain.log_format = 'json'
auto_explain.log_level = 'log'
auto_explain.log_verbose = 'on'
auto_explain.log_analyze = 'on'
auto_explain.log_buffers = 'on'
auto_explain.log_wal = 'on'
auto_explain.log_timing = 'on'
auto_explain.log_triggers = 'on'
auto_explain.sample_rate = 0.01
auto_explain.log_min_duration = 30000
auto_explain.log_nested_statements = 'on'
" >> /etc/postgresql/17/main/postgresql.conf

# Generate SSH keys
ssh-keygen -q -m PEM -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Start PostgreSQL and configure it
service postgresql start
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'changeme';\""
su - postgres -c "psql -c \"CREATE EXTENSION pg_stat_statements;\""

# Revert PostgreSQL authentication method
sed -i "s/local   all             postgres                                trust/local   all             postgres                                peer/" /etc/postgresql/17/main/pg_hba.conf

# Stop PostgreSQL (it will be started by the entrypoint script)
service postgresql stop