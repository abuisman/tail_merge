#!/usr/bin/env bash
set -euo pipefail

# Build pure gem and native gems for multiple platforms into pkg/.
# Does not publish. Use bin/release_all.sh to publish.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "[build] Repository root: $REPO_ROOT"

command -v bundle >/dev/null 2>&1 || { echo "[build] ERROR: bundler not found. Install with: gem install bundler"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "[build] ERROR: docker not found. Install and start Docker Desktop."; exit 1; }

if ! docker info >/dev/null 2>&1; then
  echo "[build] ERROR: Docker is not running. Start Docker Desktop first."
  exit 1
fi

echo "[build] Installing bundle dependencies..."
bundle install --quiet

# Determine version from lib/tail_merge/version.rb (not strictly required for build, but useful to show)
VERSION=""
if [[ -f "lib/tail_merge/version.rb" ]]; then
  VERSION=$(ruby -e 'v = File.read("lib/tail_merge/version.rb"); puts v[/VERSION\s*=\s*"([^"]+)"/, 1]')
fi
echo "[build] Version: ${VERSION:-unknown}"

echo "[build] Building pure gem..."
bundle exec rake build

# Platforms to build. Override by setting PLATFORMS env var.
PLATFORMS_DEFAULT=(x86_64-linux x64-mingw-ucrt arm64-darwin)
read -r -a PLATFORMS <<< "${PLATFORMS:-${PLATFORMS_DEFAULT[*]}}"

echo "[build] Building native gems for platforms: ${PLATFORMS[*]}"
for platform in "${PLATFORMS[@]}"; do
  echo "[build] → Building for $platform"
  bundle exec rake "native[$platform]"
done

echo "[build] Build complete. Artifacts in pkg/:"
ls -la pkg | sed 's/^/[pkg] /'


