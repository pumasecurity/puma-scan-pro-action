#!/bin/bash
set -euo pipefail

# READ INPUT VARS
PUMA_PROJECT_PATHS="${1}"
PUMA_OUTPUT_FORMATS="${2}"
PUMA_OUTPUT_FILE="${3}"
PUMA_SETTINGS_PATHS="${4}"
PUMA_VERBOSE="${5}"
PUMA_THRESHOLD_HIGH="${6}"
PUMA_THRESHOLD_MEDIUM="${7}"
PUMA_THRESHOLD_LOW="${8}"

# Restore project / solution files
for f in ${PUMA_PROJECT_PATHS//,/ }; do
  if [ -f "$f" ]; then
    echo "Restoring dependencies for '${f}':"
    # Restore dependencies
    dotnet restore "$f"
  else
    echo "ERROR: cannot find project file '${f}'." >&2
    exit 1
  fi
done

# Request GH action token for license activation
export PUMA_AUTH_TOKEN=$(curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL&audience=https://portal.pumascan.com")

# Build args and run pumascan
pumascan_command=("pumascan" "scan" "--projects" """${PUMA_PROJECT_PATHS}""" "--format" """${PUMA_OUTPUT_FORMATS}""" "--output" """${PUMA_OUTPUT_FILE}""")

# Optional args
if [[ "$PUMA_SETTINGS_PATHS" != "null" ]]; then
  pumascan_command+=("--settings" """${PUMA_SETTINGS_PATHS}""")
fi

if [[ "$PUMA_VERBOSE" == "true" ]]; then
  pumascan_command+=("--verbose")
fi

if [[ "$PUMA_THRESHOLD_HIGH" != "null" ]]; then
  pumascan_command+=("--threshold-high" """${PUMA_THRESHOLD_HIGH}""")
fi

if [[ "$PUMA_THRESHOLD_MEDIUM" != "null" ]]; then
  pumascan_command+=("--threshold-medium" """${PUMA_THRESHOLD_MEDIUM}""")
fi

if [[ "$PUMA_THRESHOLD_LOW" != "null" ]]; then
  pumascan_command+=("--threshold-low" """${PUMA_THRESHOLD_LOW}""")
fi

echo "Running pumascan with options: ${pumascan_command[*]}"
"${pumascan_command[@]}"
returnCode=$?
exit $returnCode
