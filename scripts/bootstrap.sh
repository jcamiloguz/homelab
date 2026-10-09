#!/usr/bin/env bash
# Idempotent host bootstrap for the Pi. Safe to re-run.
# Mirrors docs/01-os-setup.md and docs/02-docker.md.
# Pi OS Lite has no git: first run `sudo apt install -y git`, then clone the repo.
set -euo pipefail

DATA_DIR="${DATA_DIR:-/srv/homelab}"

echo "==> Packages"
sudo apt-get update
sudo apt-get install -y git curl htop vim unattended-upgrades ufw dnsutils bluez

echo "==> Docker"
if ! command -v docker >/dev/null; then
  curl -fsSL https://get.docker.com | sh
fi
sudo usermod -aG docker "$USER"

echo "==> Data dir: $DATA_DIR"
sudo mkdir -p "$DATA_DIR"
sudo chown "$USER:$USER" "$DATA_DIR"

echo "==> Tailscale"
if ! command -v tailscale >/dev/null; then
  curl -fsSL https://tailscale.com/install.sh | sh
fi

echo "Done. Next: log out/in (docker group), then 'sudo tailscale up --ssh --accept-dns=false'."
