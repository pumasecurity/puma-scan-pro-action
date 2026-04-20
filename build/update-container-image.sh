#!/bin/bash
set -euo pipefail

# Rewrites the tag portion of the Dockerfile FROM line. The registry and image
# (e.g., ghcr.io/pumasecurity/puma-scan-pro) are preserved; only the tag after
# the ':' is replaced. An optional trailing "AS <name>" stage alias is kept.
# Usage: update-container-image.sh <image-tag>  (e.g. 1.6.1-net10-linux-x64)

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

# Identical pattern used by the precheck and the sed substitution so the two
# cannot disagree (e.g., grep matching a form sed would silently skip).
FROM_REGEX='^(FROM [^[:space:]]+):[^[:space:]]+([[:space:]]+AS[[:space:]]+[^[:space:]]+)?[[:space:]]*$'

if ! grep -qE "${FROM_REGEX}" "$DOCKERFILE"; then
  echo "ERROR: No tagged FROM directive found in ${DOCKERFILE}" >&2
  exit 1
fi

sed -i.bak -E "s|${FROM_REGEX}|\\1:${IMAGE_TAG}\\2|" "$DOCKERFILE"

if cmp -s "$DOCKERFILE" "${DOCKERFILE}.bak"; then
  rm -f "${DOCKERFILE}.bak"
  echo "ERROR: FROM substitution made no change to ${DOCKERFILE} (already '${IMAGE_TAG}'?)" >&2
  exit 1
fi

rm -f "${DOCKERFILE}.bak"

echo "Updated ${DOCKERFILE} FROM tag to: ${IMAGE_TAG}"
