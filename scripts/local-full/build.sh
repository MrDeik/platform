#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PARALLELISM="${HULY_BUILD_PARALLELISM:-6}"
RUSH_BOOTSTRAP="$REPO_ROOT/common/scripts/install-run-rush.js"

cd "$REPO_ROOT"

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is not installed. The repository .nvmrc currently requires Node 22." >&2
  exit 1
fi

NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
if [[ "$NODE_MAJOR" != "22" ]]; then
  echo "ERROR: Node.js 22 is required; current version is $(node --version)." >&2
  exit 1
fi

if [[ ! -f "$RUSH_BOOTSTRAP" ]]; then
  echo "ERROR: Rush bootstrap was not found at $RUSH_BOOTSTRAP." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "ERROR: Docker Desktop is not running or unavailable." >&2
  exit 1
fi

echo "Building the full local image set with parallelism=$PARALLELISM"
echo "Source commit: $(git rev-parse HEAD)"

node "$RUSH_BOOTSTRAP" docker:build -p "$PARALLELISM" \
  --to @hcengineering/pod-server \
  --to @hcengineering/pod-front \
  --to @hcengineering/prod \
  --to @hcengineering/pod-account \
  --to @hcengineering/pod-workspace \
  --to @hcengineering/pod-collaborator \
  --to @hcengineering/tool \
  --to @hcengineering/pod-print \
  --to @hcengineering/pod-sign \
  --to @hcengineering/pod-analytics-collector \
  --to @hcengineering/rekoni-service \
  --to @hcengineering/pod-ai-bot \
  --to @hcengineering/import-tool \
  --to @hcengineering/pod-stats \
  --to @hcengineering/pod-fulltext \
  --to @hcengineering/pod-love \
  --to @hcengineering/pod-notification \
  --to @hcengineering/pod-mail \
  --to @hcengineering/pod-datalake \
  --to @hcengineering/pod-mail-worker \
  --to @hcengineering/pod-export \
  --to @hcengineering/pod-media \
  --to @hcengineering/pod-preview \
  --to @hcengineering/pod-link-preview \
  --to @hcengineering/pod-external \
  --to @hcengineering/pod-backup \
  --to @hcengineering/backup-api-pod \
  --to @hcengineering/pod-process \
  --to @hcengineering/pod-rating \
  --to @hcengineering/pod-worker \
  --to @hcengineering/pod-events-processor

echo
echo "Built local Huly images:"
docker image ls --format '{{.Repository}}:{{.Tag}}\t{{.Size}}' | grep '^hardcoreeng/' | sort
