#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEV_DIR="$REPO_ROOT/dev"
PROJECT_NAME="${HULY_COMPOSE_PROJECT:-huly-collective-local}"

"$REPO_ROOT/scripts/local-full/prepare-env.sh"

cd "$DEV_DIR"

COMPOSE=(docker compose \
  -p "$PROJECT_NAME" \
  --env-file .env \
  --env-file .env.local-full \
  -f docker-compose.yaml \
  -f docker-compose.local-full.yaml)

"${COMPOSE[@]}" config --quiet
"${COMPOSE[@]}" up -d --force-recreate --remove-orphans

echo
echo "Huly:      http://huly.local:8087"
echo "LiveKit:   ws://huly.local:7880"
echo "Jaeger:    http://localhost:16686"
echo "MinIO UI:  http://localhost:9001"
echo
echo "Check status with: scripts/local-full/status.sh"
