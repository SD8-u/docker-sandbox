docker build --no-cache  -t postgresubuntu17 .
docker run -dit --name postgresubuntu -p 5432:5432 -p 22:22 postgresubuntu
docker cp postgresubuntu:/root/.ssh/id_rsa ./root.key
ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost