#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "Removing generated Theos/example artifacts..."
find examples -type d \( -name .theos -o -name packages \) -prune -exec rm -rf {} +

echo "Removing local validation logs..."
rm -f ./*.log
rm -f ./inspect-*.log
rm -f ./validate-*.log
rm -f ./validate-host-pipeline-*.log
rm -f ./inspect-*test*.log

rm -f validate-host-pipeline-*.log
rm -f repro-build-*.log noop-build-*.log logos-build-*.log clean-*.log
find examples -maxdepth 2 -type f -name '*.log' -delete

echo "Removing Python caches..."
find . -type d -name '__pycache__' -prune -exec rm -rf {} +

echo "Generated artifact cleanup complete."
