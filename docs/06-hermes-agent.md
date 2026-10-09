# 06 · Hermes Agent

**Goal:** a personal AI agent on the Pi, named **PiHub**, ([Hermes Agent](https://github.com/NousResearch/hermes-agent), Nous Research), powered by my **ChatGPT subscription**, reachable from the phone via **Discord** and a private **web UI over Tailscale**.

```
phone / Mac ──► Discord (channels, push, cron output)
            └─► Open WebUI ──Tailscale HTTPS──┐
                                              ▼
              Pi · user `hermes` ── Hermes Agent ── ChatGPT (OpenAI Codex OAuth)
                                     ├─ memory + skills (~hermes/.hermes)
                                     ├─ API server 127.0.0.1:8642 (key-protected)
                                     └─ tools → Home Assistant · Hub (MCP) · homelab status
```

## Principles
- **Dedicated `hermes` user** — no sudo, not in the `docker` group (docker group = root). The agent's shell can only touch its own home.
- **Capabilities via APIs, not raw shell** — Home Assistant token, Hub MCP, read-only status endpoints.
- **Secrets stay on the Pi** — `~hermes/.hermes/.env`, `~hermes/.hermes/auth.json`. Never in this repo.
- **Admin dashboard never exposed** — use an SSH tunnel.

## Phase 1 · Install + ChatGPT login
As `<USER>`:
```bash
sudo apt install -y libatomic1                       # needed by Hermes' bundled Node on minimal images
sudo adduser --disabled-password --gecos "" hermes  # no password, no sudo
sudo -iu hermes                                      # become hermes
```
As `hermes`:
```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
source ~/.bashrc
hermes setup          # provider: OpenAI Codex → device-code login with the ChatGPT account
hermes                # first chat
```
Verify: ask *"what machine and user are you running as?"* → `hermes` on aarch64 Linux.

### Model choice (ChatGPT Plus, dedicated to Hermes)
| Model | Use | Plus limit (per 5 h, approx.) |
|---|---|---|
| **gpt-6.1-sol** ⭐ default | chat, tool calling, agent work | ~15–160 messages |
| gpt-6-luna | cron jobs, summaries, simple/high-volume tasks | ~350–3,000 |
| gpt-6-astra | only on demand (`/model`) for hard problems | ~5–45 |

- Skip the `-900k` variants (long-context; burn more quota) and older `gpt-5.6-*`.
- One agent request = several model calls (tool loops), so real limits are lower than the message counts.
- Switch any time: `hermes model` or `/model <provider:model>` in a chat.
- Reasoning effort: `high` chosen. Higher effort = slower replies and more quota per request; drop to `medium` if limits bite, `low` for quick commands like lights.

## Phase 2 · Discord
1. Private Discord server "Homelab" with channels `#hermes`, `#brief`, `#alerts`, `#lights`, `#shopping`, `#hub`.
2. [Developer Portal](https://discord.com/developers/applications) → New Application → Bot:
   - enable **Message Content Intent** + **Server Members Intent**
   - copy the **bot token** (shown once → password manager)
3. Invite the bot (View Channels, Send Messages, Embed Links, Attach Files, Read Message History) → then turn **Public Bot** off.
4. Discord → Settings → Advanced → Developer Mode → copy your **User ID** and the channel IDs.
5. As `hermes`: `hermes gateway setup` (Discord), or in `~/.hermes/.env`:
   ```
   DISCORD_BOT_TOKEN=...
   DISCORD_ALLOWED_USERS=<my user id>
   DISCORD_HOME_CHANNEL=<#brief id>
   DISCORD_FREE_RESPONSE_CHANNELS=<#hermes id>
   ```
6. Run the gateway as a service → [`hermes/hermes-gateway.service`](../hermes/hermes-gateway.service).
   Don't use the installer's own `hermes gateway install` (a *user* systemd service): under `sudo -iu hermes` there's no user session bus, so it fails with `Failed to connect to user scope bus`. The system unit runs as `hermes` anyway.

## Phase 3 · Web UI (Open WebUI over Tailscale)
1. As `hermes`, enable the API server (stays on `127.0.0.1`):
   ```bash
   KEY=$(openssl rand -hex 32); echo "$KEY"     # → also HERMES_API_KEY in the repo .env on the Pi
   hermes config set API_SERVER_ENABLED true
   hermes config set API_SERVER_KEY "$KEY"
   ```
   Restart the gateway, then: `curl -s http://127.0.0.1:8642/health`
2. As `<USER>`, in the repo: set `HERMES_API_KEY` + `WEBUI_SECRET_KEY` in `.env`, then
   ```bash
   docker compose -f services/open-webui/compose.yml --env-file .env up -d
   ```
3. Tailscale admin → DNS → enable **HTTPS certificates**. Then:
   ```bash
   sudo tailscale serve --bg 3000
   ```
   → `https://<PI_HOST>.<TAILNET>` from any tailnet device. Create the admin account, then set `OPENWEBUI_ENABLE_SIGNUP=false` and restart.
4. Phone: open the URL → *Add to Home Screen*.

Port 3000 isn't allowed from the LAN by ufw (host networking respects ufw); tailnet access is allowed via `tailscale0`.

## Phase 4 · Integrations & skills
- **Home Assistant** (built-in tools) → needs [09](09-smart-home.md): long-lived token → `HASS_TOKEN` / `HASS_URL` in `~hermes/.hermes/.env`.
- **Cron → Discord `#brief`**: morning brief (weather, calendar, Pi health, Hub spending, shopping list).
- **Hub MCP** → [07](07-hub.md).
- **Ollama on the desktop** as private/fallback model → [10](10-desktop-server.md).
- **Own skills** in `hermes/skills/` (SKILL.md / agentskills.io format, no secrets — public repo), linked into `~hermes/.hermes/skills`. First ones: `homelab-status`, `lights`, `shopping`, `morning-brief`.
- Review skills Hermes creates by itself.

## Admin dashboard
```bash
ssh -L 9119:localhost:9119 <USER>@<PI_HOST>    # then as hermes: hermes dashboard --no-open
```
Open `http://localhost:9119` on the Mac. It can read/write all keys — never bind it to the tailnet.

## Backups
`~hermes/.hermes` (memory, sessions, skills, auth) → restic, once backups exist.

## Open questions
- ChatGPT plan limits under agent + cron usage — start with few cron jobs.
- Does `hermes gateway` stay in the foreground (needed for the systemd unit)? Verify in phase 2.
