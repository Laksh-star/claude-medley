#!/usr/bin/env bash
# Rebuild dist/<skill>.zip for every skill (upload these on claude.ai, or unzip into ~/.claude/skills/).
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist && mkdir -p dist
for dir in plugins/*/skills/*/; do
  name=$(basename "$dir")
  (cd "$(dirname "$dir")" && zip -qr "../../../dist/$name.zip" "$name" -x '*.DS_Store')
  echo "dist/$name.zip"
done
