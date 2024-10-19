FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Etc/UTC

# Copy setup and start-services scripts
COPY setup.sh /usr/local/bin/
COPY start-services.sh /usr/local/bin/

# Run setup script
RUN chmod +x /usr/local/bin/setup.sh && /usr/local/bin/setup.sh

# Make start-services script executable
RUN chmod +x /usr/local/bin/start-services.sh

# Expose necessary ports
EXPOSE 5432 22

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/start-services.sh"]