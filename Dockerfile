# Container image that runs your code
FROM ghcr.io/pumasecurity/puma-scan-pro:1.6.0-net8-linux-x64

# Install lib dependencies for the entrypoint script
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  jq \
  && rm -rf /var/lib/apt/lists/*

# Copy entrypoint scripts into the action runtime image
COPY ./src/entrypoint.sh /entrypoint.sh

# Execute the scan
ENTRYPOINT ["/entrypoint.sh"]
