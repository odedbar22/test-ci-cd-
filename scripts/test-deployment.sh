#!/usr/bin/env bash
set -euo pipefail

EXPECTED_IMAGE="${1:?Usage: test-deployment.sh IMAGE}"
PF_PID=""
PF_LOG="$(mktemp)"

cleanup() {
    if [[ -n "$PF_PID" ]]; then
        kill "$PF_PID" 2>/dev/null || true
        wait "$PF_PID" 2>/dev/null || true
    fi
    rm -f "$PF_LOG"
}
trap cleanup EXIT

ACTUAL_IMAGE="$(kubectl --context minikube -n cicd-lab \
    get deployment cicd-web \
    -o jsonpath='{.spec.template.spec.containers[0].image}')"

if [[ "$ACTUAL_IMAGE" != "$EXPECTED_IMAGE" ]]; then
    echo "FAIL: deployed image differs from tested image" >&2
    exit 1
fi

kubectl --context minikube -n cicd-lab \
    port-forward service/cicd-web :80 \
    --address 127.0.0.1 >"$PF_LOG" 2>&1 &
PF_PID=$!

for attempt in {1..20}; do
    if ! kill -0 "$PF_PID" 2>/dev/null; then
        cat "$PF_LOG"
        exit 1
    fi

    PORT="$(sed -n 's/^Forwarding from 127\.0\.0\.1:\([0-9]*\) ->.*/\1/p' "$PF_LOG")"

    if [[ -n "$PORT" ]]; then
        if BASE_URL="http://127.0.0.1:$PORT" bash scripts/smoke-test.sh; then
            echo "PASS: deployed image=$ACTUAL_IMAGE"
            exit 0
        fi
    fi

    sleep 1
done

cat "$PF_LOG"
echo "FAIL: deployment HTTP check failed" >&2
exit 1
