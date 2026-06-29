#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Building Rust librust_lib_buzzing.dylib (release)..."
(cd "$SCRIPT_DIR/../rust" && cargo build --release)

echo ""
echo "=== Running SDK tests..."
cd "$SCRIPT_DIR"
dart test --concurrency=1 --reporter expanded "$@"
