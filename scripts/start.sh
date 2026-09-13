#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

APP_VERSION="${APP_VERSION:-$(cat VERSION)}"

if [[ -z "${APP_VERSION//[[:space:]]/}" ]]; then
    echo "ERROR: application version is empty" >&2
    exit 1
fi

export APP_VERSION
export PORT="${PORT:-8080}"

exec python3 -u app/server.py
