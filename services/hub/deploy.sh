#!/usr/bin/env bash
# Pull-based auto-deploy for Hub — run by hub-deploy.timer every 5 minutes (docs/07-hub.md).
#
# Follows the tag in compose.yml (default :latest, which only moves when Hub tags a release).
# When the tag points to a new image: backup → switch → wait for the health check →
#   healthy:   keep it.
#   unhealthy: restore the pre-deploy backup, go back to the previous image, and remember the
#              bad image so the next run doesn't retry it. Fix forward with a new release.
# Logs go to the journal: journalctl -u hub-deploy
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
COMPOSE=(docker compose -f "$REPO_DIR/services/hub/compose.yml" --env-file "$REPO_DIR/.env")
STATE_DIR="${HUB_DEPLOY_STATE:-$HOME/.local/state/hub-deploy}"
HEALTH_TIMEOUT=120 # seconds
PREVIOUS=hub-deploy:previous

log() { echo "[hub-deploy] $*"; }
mkdir -p "$STATE_DIR"

image="$("${COMPOSE[@]}" config --images | head -n1)"
running="$(docker inspect -f '{{.Image}}' hub 2>/dev/null || true)"

# Quiet unless it fails, so the journal only shows real events.
if ! out="$("${COMPOSE[@]}" pull --quiet hub 2>&1)"; then
  log "pull failed: $out"
  exit 1
fi
candidate="$(docker image inspect -f '{{.Id}}' "$image")"

[ "$candidate" = "$running" ] && exit 0
if [ "$candidate" = "$(cat "$STATE_DIR/bad" 2>/dev/null || true)" ]; then
  log "skipping $image: this image failed its health check before"
  exit 0
fi

version="$(docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.version"}}' "$image")"
log "new image for $image (v$version)"

backup=""
if [ -n "$running" ]; then
  backup="$(docker exec hub node dist/server/index.js backup | sed -n 's/^backup written: //p')"
  log "pre-deploy backup: $backup"
  docker tag "$running" "$PREVIOUS"
fi

"${COMPOSE[@]}" up -d --pull never hub

status=starting
waited=0
for _ in $(seq 1 "$HEALTH_TIMEOUT"); do
  status="$(docker inspect -f '{{.State.Health.Status}}' hub 2>/dev/null || echo missing)"
  [ "$status" = healthy ] || [ "$status" = unhealthy ] && break
  sleep 1
  waited=$((waited + 1))
done

if [ "$status" = healthy ]; then
  rm -f "$STATE_DIR/bad"
  docker image prune -f >/dev/null
  log "deployed v$version"
  exit 0
fi

log "v$version is $status after ${waited}s — rolling back"
echo "$candidate" >"$STATE_DIR/bad"
docker logs --tail 50 hub 2>&1 | sed 's/^/[hub] /' || true

if [ -z "$running" ]; then
  log "nothing to roll back to (first deploy)"
  exit 1
fi

"${COMPOSE[@]}" stop hub
if [ -n "$backup" ]; then
  # The new version may have migrated the schema; restore the snapshot taken just before the switch.
  docker run --rm --volumes-from hub --entrypoint sh "$PREVIOUS" \
    -c "cp '$backup' /data/hub.db && rm -f /data/hub.db-wal /data/hub.db-shm"
  log "restored $backup"
fi
docker tag "$PREVIOUS" "$image"
"${COMPOSE[@]}" up -d --pull never hub
log "rolled back to the previous image"
exit 1
