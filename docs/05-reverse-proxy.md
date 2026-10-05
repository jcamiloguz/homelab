# 05 · Reverse proxy & dashboard (idea)

- **Caddy** as reverse proxy: `pihole.home.arpa`, `app.home.arpa`, … via Pi-hole local DNS records — or use Tailscale MagicDNS + `tailscale serve` for HTTPS.
- **Homepage** (gethomepage.dev) as the landing dashboard with service widgets.

Open questions:
- `*.home.arpa` + internal CA vs. Tailscale HTTPS certs?
