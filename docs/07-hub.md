# 07 · Hub

**Hub** is my personal life-admin app (finance, shopping lists, portfolio, health). App code, design and auth model live in its **own private repo** `jcamiloguz/hub` (see its `docs/architecture.md` and `docs/auth.md`).

This doc covers the **homelab side**: running Hub on the Pi.

Stack: [`services/hub/compose.yml`](../services/hub/compose.yml) — image `ghcr.io/jcamiloguz/hub:latest` (arm64, built by Hub's CI; `:latest` moves only on Hub releases), one Node process serving the PWA, `/api`, `/mcp` and `/healthz`, SQLite in `${DATA_DIR}/hub`.

```
phone / Mac ──tailnet──► tailscale serve :443 (HTTPS + Tailscale-User-* headers)
                               │
                               ▼
                     127.0.0.1:3000 ── hub container ── /data → ${DATA_DIR}/hub/hub.db
                               ▲
PiHub (hermes) ──✗ blocked on loopback; uses https://<PI_HOST>.<TAILNET>/mcp + bearer token
```

## Port map (Pi)
| Port | Service | Exposed via |
|---|---|---|
| 3000 | Hub | `tailscale serve` **:443** |
| 3001 | Open WebUI | `tailscale serve` **:8443** |
| 8080 | Pi-hole admin (on hold) | tailnet / LAN |
| 8642 | Hermes API server | loopback only |

## Security model (why the extra steps)
Hub trusts the `Tailscale-User-Login` header that `tailscale serve` adds. Anything that can reach **`127.0.0.1:3000` directly** could forge that header and act as me.
- Hub's design assumed Hermes in its own container; here Hermes runs **on the host** as user `hermes` → block that user from Hub's loopback port (step 4).
- Requests that start **on the Pi** and go through `tailscale serve` carry the Pi owner's identity → **tag the Pi** (`tag:server`) before connecting PiHub to `/mcp`, so Pi-originated requests get **no** identity and `/api` returns 401 (phase B).

## Phase A · Deploy for me (owner only)
1. **Tailscale admin → DNS:** MagicDNS on, **HTTPS Certificates** on.
   Note: the cert puts `<PI_HOST>.<TAILNET>` in public Certificate Transparency logs (name only, nothing reachable).
2. **Pull access to the private image:** GitHub → Settings → Developer settings → **Personal access tokens (classic)** → scope **`read:packages` only**, then on the Pi:
   ```bash
   docker login ghcr.io -u <GITHUB_USER>     # paste the token as password
   ```
3. **`.env` on the Pi** (repo root):
   ```bash
   HUB_VERSION=latest          # auto-deploy each release; X.Y.Z to pin
   HUB_OWNER_LOGIN=<my Tailscale login>
   HUB_MCP_TOKEN=$(openssl rand -hex 32)
   ```
4. **Block `hermes` from Hub** — add to `/etc/ufw/before.rules`, just before the final `COMMIT`:
   ```
   # Hub: hermes must not reach Hub directly (loopback port or Docker networks).
   # -I ... 1 puts them ABOVE ufw's early "-A ufw-before-output -o lo -j ACCEPT" (an -A rule here would never match).
   -I ufw-before-output 1 -p tcp -o lo --dport 3000 -m owner --uid-owner hermes -j REJECT
   -I ufw-before-output 1 -d 172.16.0.0/12 -m owner --uid-owner hermes -j REJECT
   ```
   `sudo ufw reload`, then verify both paths fail as `hermes`:
   `sudo -u hermes curl -s -m 3 http://127.0.0.1:3000/healthz` and `sudo -u hermes curl -s -m 3 http://<hub container IP>:3000/healthz`.
5. **Run:**
   ```bash
   sudo mkdir -p /srv/homelab/hub && sudo chown 1000:1000 /srv/homelab/hub   # container runs as node (uid 1000)
   docker compose -f services/hub/compose.yml --env-file .env pull
   docker compose -f services/hub/compose.yml --env-file .env up -d
   curl -s http://127.0.0.1:3000/healthz
   ```
6. **Publish on the tailnet:**
   ```bash
   sudo tailscale serve --bg --https=443 http://127.0.0.1:3000
   tailscale serve status
   ```
7. **Open** `https://<PI_HOST>.<TAILNET>` on the Mac and phone → *Add to Home Screen* (PWA).

## Phase B · PiHub ↔ Hub (MCP)
1. Tailscale policy: add `tagOwners` for `tag:server` **and** an `ssh` rule for `tag:server` (tagged devices don't match the default `autogroup:self` SSH rule — without it, Tailscale SSH to the Pi stops working; LAN SSH stays as fallback).
2. Tag the Pi: `sudo tailscale up --advertise-tags=tag:server --ssh --accept-dns=false`.
3. Verify from the Pi: `curl -s https://<PI_HOST>.<TAILNET>/api/...` → 401 (no identity).
4. Hermes: `HUB_MCP_TOKEN` in `~hermes/.hermes/.env` + `mcp_servers.hub` in `config.yaml` (see Hub's `docs/architecture.md`), excluding `*_delete*` tools.

## Phase C · Partner access (later)
Invite to the tailnet, grant only `tag:server:443`, then grant modules in Hub's Members screen. Policy template: Hub's `docs/auth.md` (placeholders only in this public repo).

## Auto-deploy and nightly backups
Pull-based: nothing on GitHub can reach the Pi. Releasing Hub (tag `vX.Y.Z` → `:latest` moves) **is** deploying.

```
hub-deploy.timer (every 5 min) → services/hub/deploy.sh
  pull :latest ── same image? → exit (silent)
       │ new
       ▼
  backup (VACUUM INTO) → up -d → wait for healthy (≤ 120 s)
       ├─ healthy   → keep, log "deployed vX.Y.Z"
       └─ unhealthy → restore backup, previous image back, remember the bad image (not retried)
hub-backup.timer (03:00) → docker exec hub … backup   (keeps 7 in ${DATA_DIR}/hub/backups)
```

Install once (as the user in the `docker` group that ran `docker login ghcr.io`):
```bash
services/hub/install-timers.sh        # renders units into /etc/systemd/system, enables both timers
systemctl list-timers 'hub-*'
```

Watch it: `journalctl -u hub-deploy -f` · deploy now: `sudo systemctl start hub-deploy` · pause: `sudo systemctl stop hub-deploy.timer` (or pin `HUB_VERSION=X.Y.Z`).

After a rollback the bad image is skipped until a newer release exists — fix forward with a new Hub release. State: `~/.local/state/hub-deploy/bad`.

## Operations
- **Upgrade:** automatic (above). Manual: `sudo systemctl start hub-deploy`. Check `/healthz` (shows version, stage + commit).
- **Staging** (`:develop` image) on another port/serve port — only if needed.
- **Backups:** nightly snapshot + one before every deploy in `${DATA_DIR}/hub/backups` (keeps 7) → restic once it exists.
- **Logs:** `docker logs -f hub`.

## Rules
- No real financial, portfolio or health data in **either** repo.
- Real `HUB_OWNER_LOGIN`, `HUB_MCP_TOKEN` and the GHCR token live only on the Pi.
