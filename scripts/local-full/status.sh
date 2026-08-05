#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEV_DIR="$REPO_ROOT/dev"
PROJECT_NAME="${HULY_COMPOSE_PROJECT:-huly-collective-local}"

cd "$DEV_DIR"

COMPOSE=(docker compose -p "$PROJECT_NAME" --env-file .env --env-file .env.local-full \
  -f docker-compose.yaml -f docker-compose.ext.yaml -f docker-compose.local-full.yaml)

"${COMPOSE[@]}" ps

echo
echo "Container resource snapshot:"
docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.PIDs}}' \
  $("${COMPOSE[@]}" ps -q)
