#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

export APP_VERSION="${APP_VERSION:-$(cat VERSION)}"
export PORT="${PORT:-8080}"

exec python3 -u app/server.py
