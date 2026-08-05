#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEV_DIR="$REPO_ROOT/dev"
PROJECT_NAME="${HULY_COMPOSE_PROJECT:-huly-collective-local}"
INTERVAL="${1:-10}"
OUTPUT="${2:-$REPO_ROOT/huly-stats-$(date +%Y%m%d-%H%M%S).csv}"

cd "$DEV_DIR"
COMPOSE=(docker compose -p "$PROJECT_NAME" --env-file .env --env-file .env.local-full \
  -f docker-compose.yaml -f docker-compose.ext.yaml -f docker-compose.local-full.yaml)

CONTAINERS="$("${COMPOSE[@]}" ps -q)"
if [[ -z "$CONTAINERS" ]]; then
  echo "ERROR: no running containers found for project $PROJECT_NAME." >&2
  exit 1
fi

printf 'timestamp,container,cpu_percent,memory_usage,memory_percent,network_io,block_io,pids\n' > "$OUTPUT"
echo "Writing stats every ${INTERVAL}s to $OUTPUT. Press Ctrl+C to stop."

while true; do
  TS="$(date --iso-8601=seconds)"
  docker stats --no-stream \
    --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}|{{.NetIO}}|{{.BlockIO}}|{{.PIDs}}' \
    $CONTAINERS | while IFS='|' read -r name cpu mem memperc net block pids; do
      printf '"%s","%s","%s","%s","%s","%s","%s","%s"\n' \
        "$TS" "$name" "$cpu" "$mem" "$memperc" "$net" "$block" "$pids" >> "$OUTPUT"
    done
  sleep "$INTERVAL"
done
