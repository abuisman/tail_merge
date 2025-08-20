#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

"$REPO_ROOT/bin/build_all.sh"

# Determine version
VERSION=$(ruby -e 'v = File.read("lib/tail_merge/version.rb"); puts v[/VERSION\s*=\s*"([^"]+)"/, 1]')
echo "[release] Detected version: $VERSION"

"$REPO_ROOT/bin/push_all.sh" "$VERSION"

echo "[release] All done! Published version ${VERSION}."


