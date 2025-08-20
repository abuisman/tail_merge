#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

"$REPO_ROOT/bin/build_all.sh"

# Determine version
VERSION=$(ruby -e 'v = File.read("lib/tail_merge/version.rb"); puts v[/VERSION\s*=\s*"([^"]+)"/, 1]')
echo "[release] Detected version: $VERSION"

echo "[release] Pushing gems to RubyGems..."
shopt -s nullglob
GEMS_TO_PUSH=(
  "pkg/tail_merge-${VERSION}.gem"
  "pkg/tail_merge-${VERSION}-"*.gem
)

if [[ ${#GEMS_TO_PUSH[@]} -eq 0 ]]; then
  echo "[release] ERROR: No gems found to push for version ${VERSION}"
  exit 1
fi

for gem_file in "${GEMS_TO_PUSH[@]}"; do
  echo "[release] → Pushing $(basename "$gem_file")"
  gem push "$gem_file"
done

echo "[release] All done! Published version ${VERSION}."


