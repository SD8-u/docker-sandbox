podman build --no-cache --network=host -t postgresubuntu17 .
podman run -dit --name postgresubuntu17 --cap-add SYS_CHROOT --cap-add AUDIT_WRITE --cap-add CAP_NET_RAW -p 5432:5432 -p 22:22 postgresubuntu17
podman cp postgresubuntu17:/root/.ssh/id_rsa ./root.key
ssh -i root.key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost
# in case of ssh issues run command below
# podman exec -it postgresubuntu17 bash
