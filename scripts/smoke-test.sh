#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "Checking ${BASE_URL}/health"

BODY="$(curl --fail --silent --show-error \
  --connect-timeout 3 \
  --max-time 5 \
  "${BASE_URL}/health")"

printf '%s' "$BODY" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
if data.get("status") != "ok":
    sys.exit("FAIL: health status is not ok")

print("PASS: application is healthy, version=" + str(data.get("version")))
'
