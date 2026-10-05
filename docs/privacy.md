# Privacy rules

This repo is **public**. Before every commit, check:

- [ ] No real IPs (LAN or Tailscale), MAC addresses, hostnames or tailnet names
- [ ] No emails, usernames, account IDs, API keys, tokens, OAuth files
- [ ] No real financial, portfolio or health data (seed/test data must be fake)
- [ ] Screenshots are redacted (IPs, device names, balances, client lists)
- [ ] Logs pasted in docs are scrubbed

## Conventions

| Use this placeholder | Instead of |
|---|---|
| `<PI_IP>` | the Pi's LAN IP |
| `<PI_TS_IP>` | the Pi's Tailscale IP |
| `<PI_HOST>` | the Pi's hostname |
| `<TAILNET>` | the tailnet name (`xxxx.ts.net`) |
| `<USER>` | the Linux user |

## Mechanics

- Secrets go in `.env` (gitignored). Only `.env.example` with placeholder values is committed.
- Service data lives outside the repo (`$DATA_DIR`, default `/srv/homelab`).
- `gitleaks` runs as a pre-commit hook (`pre-commit install`). Manual scan: `gitleaks detect -v`.
- Quick grep before pushing:
  ```bash
  git grep -nE '([0-9]{1,3}\.){3}[0-9]{1,3}|@[a-z0-9-]+\.[a-z]{2,}|ts\.net'
  ```
  (Docker-internal ranges like `172.30.0.x` in compose files are fine.)
