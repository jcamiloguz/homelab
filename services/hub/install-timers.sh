#!/usr/bin/env bash
# Installs Hub's auto-deploy and nightly backup timers (docs/07-hub.md › Auto-deploy). Safe to re-run.
# Run as the user that is in the docker group and ran `docker login ghcr.io`.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
SRC="$REPO_DIR/services/hub/systemd"

for unit in hub-deploy.service hub-deploy.timer hub-backup.service hub-backup.timer; do
  sed -e "s|@USER@|$USER|g" -e "s|@REPO_DIR@|$REPO_DIR|g" "$SRC/$unit" | sudo tee "/etc/systemd/system/$unit" >/dev/null
done

sudo systemctl daemon-reload
sudo systemctl enable --now hub-deploy.timer hub-backup.timer
systemctl list-timers 'hub-*' --no-pager
