# homelab

My Raspberry Pi 5 AI homelab — documented in public, built step by step.

> **Privacy note:** this repo is public. No IPs, hostnames, emails, tokens or real personal data are committed.
> Secrets live in a local, gitignored `.env`. See [docs/privacy.md](docs/privacy.md).

## Hardware

| Part | Choice |
|---|---|
| Board | Raspberry Pi 5 (8/16 GB) |
| Storage | NVMe SSD via M.2 HAT |
| Access | Tailscale (no open ports) |

Details: [docs/00-hardware.md](docs/00-hardware.md)

## Roadmap

| # | Topic | Status |
|---|---|---|
| 01 | [OS setup & hardening](docs/01-os-setup.md) | ⏳ planned |
| 02 | [Docker](docs/02-docker.md) | ⏳ planned |
| 03 | [Tailscale](docs/03-tailscale.md) | ⏳ planned |
| 04 | [Pi-hole + Unbound](docs/04-pihole.md) | ⏳ planned |
| 05 | [Reverse proxy & dashboard](docs/05-reverse-proxy.md) | 💡 idea |
| 06 | [Hermes Agent (ChatGPT account)](docs/06-hermes-agent.md) | 💡 idea |
| 07 | [Super app](docs/07-super-app.md) — finance, shopping list, portfolio, health | 💡 idea |

Status legend: 💡 idea · ⏳ planned · 🚧 in progress · ✅ done · ❌ dropped

More ideas: [docs/ideas.md](docs/ideas.md) · Experiment log: [docs/journal/](docs/journal/)

## Layout

```
docs/              step-by-step guides + journal
services/<name>/   one docker compose stack per service
apps/super-app/    my custom self-hosted app
scripts/           host bootstrap / helper scripts
```

## Usage

```bash
cp .env.example .env   # fill in real values locally — never commit .env
docker compose -f services/pihole/compose.yml --env-file .env up -d
```
