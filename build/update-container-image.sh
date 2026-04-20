#!/bin/bash
set -euo pipefail

# Rewrites the tag portion of the Dockerfile FROM line. The registry and image
# (e.g., ghcr.io/pumasecurity/puma-scan-pro) are preserved; only the tag after
# the last ':' is replaced.
# Usage: update-container-image.sh <image-tag>  (e.g. 1.6.1-net8-linux-x64)

if [ $# -ne 1 ]; then
  echo "Usage: $0 <image-tag>" >&2
  exit 1
fi

IMAGE_TAG="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKERFILE="${SCRIPT_DIR}/../Dockerfile"

if [ ! -f "$DOCKERFILE" ]; then
  echo "ERROR: Dockerfile not found at ${DOCKERFILE}" >&2
  exit 1
fi

if ! grep -qE '^FROM [^[:space:]]+:[^[:space:]]+' "$DOCKERFILE"; then
  echo "ERROR: No tagged FROM directive found in ${DOCKERFILE}" >&2
  exit 1
fi

sed -i.bak -E "s|^(FROM .*):[^:[:space:]]+[[:space:]]*$|\\1:${IMAGE_TAG}|" "$DOCKERFILE"
rm -f "${DOCKERFILE}.bak"

echo "Updated ${DOCKERFILE} FROM tag to: ${IMAGE_TAG}"
