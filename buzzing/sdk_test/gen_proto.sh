#!/bin/bash
# 生成 sdk_test 的 protobuf Dart idl 文件（不提交 git，每次运行前自动生成）。
# 与 buzzing/lib/models/idl 保持一致：跳过 office.proto / card.proto（客户端未生成）。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROTO_DIR="$(cd "$SCRIPT_DIR/../../proto" && pwd)"
OUT_DIR="$SCRIPT_DIR/lib/proto"

echo "=== Generating SDK test proto (dart) -> $OUT_DIR"
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cd "$PROTO_DIR"
for f in *.proto; do
  case "$f" in
    office.proto | card.proto) continue ;;
  esac
  protoc --proto_path=. --dart_out="$OUT_DIR" "$f"
done

echo "=== Done: $(ls "$OUT_DIR" | wc -l | tr -d ' ') files generated."
