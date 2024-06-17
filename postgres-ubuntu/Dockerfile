FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Etc/UTC

# Install ssh and postgres
RUN apt-get update && apt-get install -y openssh-server nano less && \
    apt-get install -y postgresql && \
    mkdir /var/run/sshd && \
    echo 'root:changeme' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf && \
    sed -i "s/#shared_preload_libraries = ''/shared_preload_libraries = 'pg_stat_statements'/" /etc/postgresql/16/main/postgresql.conf && \
    sed -i "s/local   all             postgres                                peer/local   all             postgres                                trust/" /etc/postgresql/16/main/pg_hba.conf && \
    echo "host    all             all             0.0.0.0/0               scram-sha-256" | tee -a /etc/postgresql/16/main/pg_hba.conf && \
    echo "host    all             all             ::/0                    scram-sha-256" | tee -a /etc/postgresql/16/main/pg_hba.conf

RUN ssh-keygen -q -m PEM -t rsa -b 4096 -f /root/.ssh/id_rsa -N '' && \
    cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys 

RUN service postgresql start && psql postgres postgres -c "ALTER USER postgres WITH PASSWORD 'changeme'"

RUN sed -i "s/local   all             postgres                                trust/local   all             postgres                                peer/" /etc/postgresql/16/main/pg_hba.conf 

COPY start-services.sh ./start-services.sh
RUN chmod +x ./start-services.sh
CMD ["./start-services.sh"]

# docker build --no-cache  -t postgresdockerfile .
# docker run -dit --name postgrescontainer -p 5432:5432 -p 22:22 postgresdockerfile
# docker cp postgrescontainer:/root/.ssh/id_rsa ./root.key
