#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

VERSION="$(cat VERSION)"
OUTPUT="dist/cicd-lab-${VERSION}.tar.gz"

mkdir -p dist

tar -czf "$OUTPUT" \
  app/server.py \
  scripts/start.sh \
  VERSION

echo "Built: $OUTPUT"
