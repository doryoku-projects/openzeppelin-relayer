FROM openzeppelin/openzeppelin-relayer:latest

# Copy configuration templates and entrypoint
COPY config /app/config
COPY entrypoint.sh /app/entrypoint.sh

# Ensure script is executable
RUN chmod +x /app/entrypoint.sh

# Let Railway know which port is exposed
EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
