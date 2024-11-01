podman build --no-cache  -t postgresubuntu17 .
podman run -dit --name postgresubuntu17 -p 5432:5432 -p 22:22 postgresubuntu17
podman cp postgresubuntu17:/root/.ssh/id_rsa ./root.key
ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
# in case of ssh issues run command below
# podman exec -it postgresubuntu17 bash
