#!/usr/bin/env bash
# protobuf 使用 runtime 加载（protobufjs 直接加载 .proto 文件），无需预编译。
# 确保 proto/*.proto 文件存在即可。
echo "Runtime proto loading is used. No pre-compilation needed."
echo "Proto files location: $(cd "$(dirname "$0")/../proto" && pwd)"
