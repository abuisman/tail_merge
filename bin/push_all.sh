#!/usr/bin/env bash
set -euo pipefail

# Push all gem artifacts for a given version from pkg/ to RubyGems.
# Usage:
#   bin/push_all.sh <version>
# or
#   VERSION=0.4.1 bin/push_all.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

VERSION=${1:-${VERSION:-}}
if [[ -z "${VERSION}" ]]; then
  if [[ -f "lib/tail_merge/version.rb" ]]; then
    VERSION=$(ruby -e 'v = File.read("lib/tail_merge/version.rb"); puts v[/VERSION\s*=\s*"([^"]+)"/, 1]')
  fi
fi

if [[ -z "${VERSION}" ]]; then
  echo "[push] ERROR: VERSION not provided and could not be detected."
  echo "[push] Usage: bin/push_all.sh <version> or VERSION=... bin/push_all.sh"
  exit 1
fi

echo "[push] Version: ${VERSION}"

if [[ -z "${GEM_HOST_API_KEY:-}" ]]; then
  echo "[push] NOTE: GEM_HOST_API_KEY is not set. gem push will use ~/.gem/credentials if available."
fi

shopt -s nullglob
GEMS_TO_PUSH=(
  "pkg/tail_merge-${VERSION}.gem"
  "pkg/tail_merge-${VERSION}-"*.gem
)

if [[ ${#GEMS_TO_PUSH[@]} -eq 0 ]]; then
  echo "[push] ERROR: No gems found in pkg/ for version ${VERSION}"
  exit 1
fi

for gem_file in "${GEMS_TO_PUSH[@]}"; do
  echo "[push] → Pushing $(basename "$gem_file")"
  gem push "$gem_file"
done

echo "[push] Done. Pushed ${#GEMS_TO_PUSH[@]} gem(s) for version ${VERSION}."


