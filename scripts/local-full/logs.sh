#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEV_DIR="$REPO_ROOT/dev"
PROJECT_NAME="${HULY_COMPOSE_PROJECT:-huly-collective-local}"
TAIL_LINES="${HULY_LOG_TAIL:-300}"
FOLLOW=false
SERVICE=""

usage() {
  cat <<'USAGE'
Usage:
  scripts/local-full/logs.sh [service]
  scripts/local-full/logs.sh --follow [service]

Without --follow, prints the latest logs and exits.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--follow)
      FOLLOW=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$SERVICE" ]]; then
        echo "ERROR: only one service name may be supplied." >&2
        usage >&2
        exit 2
      fi
      SERVICE="$1"
      ;;
  esac
  shift
done

cd "$DEV_DIR"
COMPOSE=(docker compose -p "$PROJECT_NAME" --env-file .env --env-file .env.local-full \
  -f docker-compose.yaml -f docker-compose.ext.yaml -f docker-compose.local-full.yaml)

ARGS=(logs --tail="$TAIL_LINES" --no-color)
if [[ "$FOLLOW" == true ]]; then
  ARGS+=(-f)
fi
if [[ -n "$SERVICE" ]]; then
  ARGS+=("$SERVICE")
fi

"${COMPOSE[@]}" "${ARGS[@]}"
