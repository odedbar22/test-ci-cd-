#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:?Usage: test-image.sh IMAGE}"
CONTAINER_ID=""

cleanup() {
    if [[ -n "$CONTAINER_ID" ]]; then
        docker logs "$CONTAINER_ID" || true
        docker rm -f "$CONTAINER_ID" >/dev/null || true
    fi
}
trap cleanup EXIT

CONTAINER_ID="$(docker run -d \
    -p 127.0.0.1::8080 \
    "$IMAGE")"

ADDRESS="$(docker port "$CONTAINER_ID" 8080/tcp)"
BASE_URL="http://${ADDRESS}"

for attempt in {1..15}; do
    if BASE_URL="$BASE_URL" bash scripts/smoke-test.sh; then
        exit 0
    fi
    sleep 2
done

echo "FAIL: container did not pass the health check" >&2
exit 1
