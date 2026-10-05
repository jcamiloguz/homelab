# 03 · Tailscale

**Goal:** reach the homelab from anywhere with no open router ports, and use Pi-hole as DNS for every device on the tailnet.

## Install on the Pi
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --ssh --accept-dns=false
tailscale ip -4                     # → <PI_TS_IP>
```
`--accept-dns=false` on the Pi avoids a loop (the Pi itself shouldn't use tailnet DNS pointing to itself).

## Admin console (login.tailscale.com)
1. **Machines** → the Pi → *Disable key expiry*.
2. **DNS** → *Nameservers* → add custom `<PI_TS_IP>` → enable **Override local DNS**.
3. Enable **MagicDNS** (gives `<PI_HOST>.<TAILNET>` names) and optionally **HTTPS certificates**.

Install Tailscale on phone/laptop → ads blocked everywhere.

## Optional
- Exit node: `sudo tailscale up --advertise-exit-node ...` (enable IP forwarding first).
- Subnet router for LAN devices that can't run Tailscale.

## Verify
- From phone on mobile data: `http://<PI_TS_IP>:8080/admin` loads Pi-hole.
- Pi-hole Query Log shows queries from tailnet devices.
