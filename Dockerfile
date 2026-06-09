FROM openzeppelin/openzeppelin-relayer:latest

# Copy configuration templates and entrypoint with correct ownership and permissions
COPY --chown=nonroot:nonroot config /app/config
COPY --chown=nonroot:nonroot --chmod=755 entrypoint.sh /app/entrypoint.sh

# Let Railway know which port is exposed
EXPOSE 8080

ENTRYPOINT ["/bin/sh", "/app/entrypoint.sh"]
