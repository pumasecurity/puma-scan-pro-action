# Container image that runs your code
FROM ghcr.io/pumasecurity/puma-scan-pro:1.6.0-net8-linux-x64

# Copy entrypoint scripts into the action runtime image
COPY ./src/entrypoint.sh /entrypoint.sh

# Execute the scan
ENTRYPOINT ["/entrypoint.sh"]
