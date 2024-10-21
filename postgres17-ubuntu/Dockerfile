FROM ubuntu:latest

ARG TZ=Etc/UTC

COPY setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh && /usr/local/bin/setup.sh
COPY start-services.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start-services.sh

EXPOSE 5432 22

ENTRYPOINT ["/usr/local/bin/start-services.sh"]