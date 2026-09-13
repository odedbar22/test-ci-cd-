#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

EXPECTED_VERSION="${EXPECTED_VERSION:-$(cat "$PROJECT_DIR/VERSION")}"
if [[ -z "${EXPECTED_VERSION//[[:space:]]/}" ]]; then
    echo "FAIL: expected version is empty" >&2
    exit 1
fi
export EXPECTED_VERSION

echo "Checking ${BASE_URL}/health"

BODY="$(curl --fail --silent --show-error \
    --connect-timeout 3 \
    --max-time 5 \
    "${BASE_URL}/health")"

printf '%s' "$BODY" | python3 -c '
import json
import os
import sys

data = json.load(sys.stdin)
expected = os.environ["EXPECTED_VERSION"]
actual = data.get("version")

if data.get("status") != "ok":
    sys.exit("FAIL: health status is not ok")

if actual != expected:
    sys.exit(f"FAIL: expected version={expected!r}, got={actual!r}")

print(f"PASS: application is healthy, version={actual}")
'
