#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEV_DIR="$REPO_ROOT/dev"
PROJECT_NAME="${HULY_COMPOSE_PROJECT:-huly-collective-local}"
SERVICE="${1:-}"

cd "$DEV_DIR"
COMPOSE=(docker compose -p "$PROJECT_NAME" --env-file .env --env-file .env.local-full \
  -f docker-compose.yaml -f docker-compose.ext.yaml -f docker-compose.local-full.yaml)

if [[ -n "$SERVICE" ]]; then
  "${COMPOSE[@]}" logs --tail=300 -f "$SERVICE"
else
  "${COMPOSE[@]}" logs --tail=100 -f
fi
