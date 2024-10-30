docker build --no-cache  -t postgresubuntu17 .
docker run -dit --privileged --name postgresubuntu17 --network nfs_network -p 5432:5432 -p 22:22 postgresubuntu17 
docker cp postgresubuntu17:/root/.ssh/id_rsa ./root.key
ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost