# 04 · Pi-hole + Unbound

**Goal:** network-wide ad blocking with a private recursive resolver (no Google/Cloudflare upstream).

Stack: [`services/pihole/compose.yml`](../services/pihole/compose.yml)
- `pihole` — DNS on `:53`, web UI on `:8080` (80/443 left for the reverse proxy)
- `unbound` — recursive resolver, only reachable from Pi-hole on an internal Docker network

## Run
```bash
cp .env.example .env      # set PIHOLE_PASSWORD
docker compose -f services/pihole/compose.yml --env-file .env up -d
docker compose -f services/pihole/compose.yml logs -f
```
UI: `http://<PI_IP>:8080/admin`

## Point clients at it
- **LAN:** router DHCP → DNS server = `<PI_IP>` (only that one, no fallback, or ads leak through).
- **Tailnet:** see [03-tailscale.md](03-tailscale.md).

## Verify
```bash
dig @<PI_IP> example.com           # resolves
dig @<PI_IP> doubleclick.net       # 0.0.0.0 → blocked
```
Unbound DNSSEC check: `dig @<PI_IP> dnssec-failed.org` → `SERVFAIL`.

## Ideas
- Extra blocklists (e.g. Hagezi), local DNS records for `*.home.arpa` services.
