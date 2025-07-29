# PostgreSQL SSL Connection Guide

## Overview
This guide explains how to connect to your PostgreSQL container from Windows using SSL encryption. The setup script now generates SSL certificates and configures PostgreSQL to require SSL for remote connections.

## What the SSL Configuration Does

### Certificate Generation
- Creates a self-signed SSL certificate valid for 365 days
- Generates a 4096-bit RSA private key
- Sets proper file permissions and ownership for PostgreSQL

### PostgreSQL SSL Settings
- Enables SSL (`ssl = on`)
- Configures certificate and key file paths
- Sets minimum TLS version to 1.2
- **SSL connections use passwordless authentication (trust)**
- **Non-SSL connections require password authentication**
- Allows both SSL and non-SSL connections from remote hosts

## Getting the Certificate from Container

### Option 1: Copy from Running Container
```powershell
# Get the container ID or name
docker ps

# Copy the certificate to your Windows machine
docker cp <container_name_or_id>:/tmp/postgres-server.crt C:\temp\postgres-server.crt
```

### Option 2: Mount Volume (Recommended for persistent access)
When running the container, mount a volume to access the certificate:
```powershell
docker run -d -p 5432:5432 -p 2222:22 -v C:\temp\postgres-certs:/tmp/certs your-postgres-image
```

Then copy the certificate inside the container:
```bash
cp /var/lib/postgresql/17/main/ssl/server.crt /tmp/certs/
```

## Connecting from Windows

### Using psql (PostgreSQL Client)
```powershell
# Connect with SSL - no password required
psql "host=localhost port=5432 dbname=redgatemonitor user=redgatemonitor sslmode=require"

# Connect without SSL - password required
psql "host=localhost port=5432 dbname=redgatemonitor user=redgatemonitor sslmode=disable"

# Connect with certificate verification (after installing the certificate)
psql "host=localhost port=5432 dbname=redgatemonitor user=redgatemonitor sslmode=verify-ca sslcert=C:\temp\postgres-server.crt"
```

### Using Connection String
```
# SSL connection - no password required
Host=localhost;Port=5432;Database=redgatemonitor;Username=redgatemonitor;SSL Mode=Require;Trust Server Certificate=true

# Non-SSL connection - password required
Host=localhost;Port=5432;Database=redgatemonitor;Username=redgatemonitor;Password=changeme;SSL Mode=Disable
```

### Using pgAdmin 4
1. Open pgAdmin 4
2. Create a new server connection
3. In the "General" tab, set the name
4. In the "Connection" tab:
   - Host: localhost (or your container's IP)
   - Port: 5432
   - Database: redgatemonitor
   - Username: redgatemonitor
   - Password: changeme
5. In the "SSL" tab:
   - SSL Mode: Require
   - Client Certificate: (leave empty for self-signed)
   - Client Key: (leave empty)
   - Root Certificate: Browse to your copied `postgres-server.crt` file
   - Certificate Revocation List: (leave empty)

### Using .NET Applications (C#)
```csharp
// SSL connection - no password required
var connectionStringSSL = "Host=localhost;Port=5432;Database=redgatemonitor;Username=redgatemonitor;SSL Mode=Require;Trust Server Certificate=true";

// Non-SSL connection - password required
var connectionStringNoSSL = "Host=localhost;Port=5432;Database=redgatemonitor;Username=redgatemonitor;Password=changeme;SSL Mode=Disable";
```

### Using JDBC (Java)
```java
// SSL connection - no password required
String urlSSL = "jdbc:postgresql://localhost:5432/redgatemonitor?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory&user=redgatemonitor";

// Non-SSL connection - password required
String urlNoSSL = "jdbc:postgresql://localhost:5432/redgatemonitor?ssl=false&user=redgatemonitor&password=changeme";
```

### Using Python (psycopg2)
```python
import psycopg2

# SSL connection - no password required
conn_ssl = psycopg2.connect(
    host="localhost",
    port=5432,
    database="redgatemonitor",
    user="redgatemonitor",
    sslmode="require"
)

# Non-SSL connection - password required
conn_no_ssl = psycopg2.connect(
    host="localhost",
    port=5432,
    database="redgatemonitor",
    user="redgatemonitor",
    password="changeme",
    sslmode="disable"
)
```

## SSL Modes Explained

- **disable**: No SSL connection
- **allow**: Try non-SSL, then SSL if that fails
- **prefer**: Try SSL first, then non-SSL (default)
- **require**: SSL connection required, but no certificate verification
- **verify-ca**: SSL required and server certificate must be verified
- **verify-full**: SSL required, certificate verified, and hostname must match

## Security Considerations

### For Development/Testing
- `sslmode=require` provides passwordless authentication for convenience
- `sslmode=disable` still requires password authentication for security
- Self-signed certificates are acceptable

### For Production
1. Replace self-signed certificates with certificates from a trusted CA
2. Consider requiring password authentication even for SSL connections for added security
3. Use `sslmode=verify-full` for maximum security
4. Ensure hostname in certificate matches the actual hostname
5. Regularly rotate certificates before expiration

## Troubleshooting

### Common Issues
1. **Connection refused**: Ensure the container is running and port 5432 is exposed
2. **SSL required**: Check that you're using SSL mode in your connection string
3. **Certificate verification failed**: Use `Trust Server Certificate=true` for self-signed certificates
4. **Permission denied**: Verify username and password are correct

### Checking SSL Status
Connect to the database and run:
```sql
SELECT ssl_is_used();
SELECT version();
SHOW ssl;
```

### Viewing Active Connections
```sql
SELECT datname, usename, client_addr, ssl, ssl_version, ssl_cipher 
FROM pg_stat_ssl 
JOIN pg_stat_activity ON pg_stat_ssl.pid = pg_stat_activity.pid;
```

## Container Startup
The container will start both SSH (port 22) and PostgreSQL (port 5432) services. SSL is automatically configured and enabled during the setup process.

Default credentials:
- PostgreSQL: redgatemonitor/changeme
- SSH: root/changeme
