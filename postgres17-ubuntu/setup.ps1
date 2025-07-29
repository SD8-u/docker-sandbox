podman build --no-cache --network=host -t postgresubuntu17 .

# Create certs directory if it doesn't exist
if (-not (Test-Path "certs")) {
    New-Item -ItemType Directory -Name "certs" -Force
    Write-Host "Created certs directory" -ForegroundColor Green
}

podman run -dit  --shm-size=256m --name postgresubuntu17 --cap-add SYS_CHROOT --cap-add AUDIT_WRITE --cap-add CAP_NET_RAW -p 5432:5432 -p 22:22 -v ${PWD}\certs:/tmp/certs postgresubuntu17

# Wait for container to fully start
Write-Host "Waiting for container to start..."
Start-Sleep -Seconds 10

# Copy SSH key
podman cp postgresubuntu17:/root/.ssh/id_rsa ./root.key

# Copy SSL certificate
Write-Host "Copying SSL certificate..."
if (Test-Path ".\certs\server.crt") {
    Write-Host "SSL certificate available at: .\certs\server.crt"
} else {
    Write-Host "Warning: SSL certificate not found. Container might still be starting."
}

Write-Host "Container is ready!"
Write-Host "PostgreSQL SSL connection: psql `"host=localhost port=5432 dbname=redgatemonitor user=redgatemonitor password=changeme sslmode=require`""
Write-Host "SSH connection: ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost"
Write-Host ""
Write-Host "To connect via SSH, run:"
Write-Host "ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost"
Write-Host ""
Write-Host "In case of SSH issues, run:"
Write-Host "podman exec -it postgresubuntu17 bash"
