#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing test dependencies ==="
pip install -q -r "$SCRIPT_DIR/requirements.txt"

echo ""
echo "=== Running integration tests ==="
cd "$SCRIPT_DIR"
pytest . -v \
  --html=report.html \
  --self-contained-html \
  -x

echo ""
echo "=== Report generated: $SCRIPT_DIR/report.html ==="
