# 07 · Hub (idea)

**Hub** is my personal life-admin app (finance, shopping lists, portfolio, health). The app has its **own private repo**: `jcamiloguz/hub` — design, roadmap and code live there.

This doc only covers the **homelab side**: how Hub runs on the Pi.

## Deployment (plan)
- Hub repo builds an `arm64` Docker image.
- This repo deploys it via `services/hub/compose.yml` (to add when there's an image).
- Data in `${DATA_DIR}/hub` (Postgres/SQLite volume) → included in restic backups.
- Reachable only over Tailscale; HTTPS + PWA install via `tailscale serve` → [05](05-reverse-proxy.md).
- Hermes Agent talks to Hub's MCP server over the tailnet → [06](06-hermes-agent.md).

## Rules
- No real financial, portfolio or health data in **either** repo.
- Hub secrets stay in `.env` on the Pi.
