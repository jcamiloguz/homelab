# 09 · Smart home — Hue Play lights without a Bridge

**Goal:** control 2× Hue Play lights from anywhere, without buying the Hue Bridge.

**Problem:** without a Bridge, the Hue app talks to the lights over Bluetooth (~10 m), so they only work from the room.
**Fix:** the Pi lives in the same room and controls them over its built-in Bluetooth via Home Assistant's **Philips Hue BLE** integration (HA 2025.12+). Tailscale makes Home Assistant reachable from anywhere.

```
phone (anywhere) ──Tailscale──► Home Assistant (Pi) ──Bluetooth──► Hue Play ×2
```

Stack: [`services/home-assistant/compose.yml`](../services/home-assistant/compose.yml)
- `network_mode: host` + `/run/dbus` mount → HA uses the host's BlueZ stack.

## 1. Host Bluetooth
```bash
sudo apt install -y bluez
sudo systemctl enable --now bluetooth
bluetoothctl show            # Powered: yes
```

## 2. Run Home Assistant
```bash
docker compose -f services/home-assistant/compose.yml --env-file .env up -d
```
UI: `http://<PI_TS_IP>:8123` (tailnet) — create the owner account on first visit.

Host networking means ufw *does* apply here (unlike published ports):
- Tailnet: already allowed by `ufw allow in on tailscale0`.
- LAN (optional): `sudo ufw allow from 192.168.0.0/16 to any port 8123 proto tcp`.

## 3. Pair the lights
Settings → Devices & services → the Bluetooth integration should appear (discovered adapter) → set it up.

Then pair each Play light, one of two ways:
- **Keep the Hue app working too:** Hue app → light → *Voice assistants* → *Make discoverable* → it shows up in HA as Philips Hue BLE.
- **HA only:** factory-reset the light → it enters pairing mode → add it in HA.

## 4. Remote access
- Phone: install the **Home Assistant** app, server URL `http://<PI_HOST>.<TAILNET>:8123` with Tailscale on.
- Nicer: `tailscale serve` for HTTPS → see [05-reverse-proxy.md](05-reverse-proxy.md).

## Verify
- Lights toggle from the HA dashboard on the Pi's network.
- Phone on mobile data + Tailscale → lights toggle.
- Reboot the Pi → lights still controllable without re-pairing.

## Gotchas
- **Hue Play is not in the integration's tested-model list** (it says other models should work). If pairing fails, note the model/firmware here and fall back to a Zigbee dongle + Zigbee2MQTT.
- **No auto-reconnect:** if a light loses its connection, reload the integration. Workaround: an HA automation that reloads it when a light goes `unavailable`.
- Only the adapter used for pairing can control the light — re-pair if you change adapter/Pi.
- Factory-reset lights show up as new devices (randomized Bluetooth address).
- Keep the Pi within a few metres of the lights; metal cases and the Pi's own USB 3 ports can weaken 2.4 GHz signals.
- No Hue Sync (TV/PC entertainment) without a Bridge.

## Ideas
- Automations: on at sunset, warm/dim at bedtime, off when everyone leaves.
- Hermes Agent: "turn the lights purple" via HA's API/MCP.
- Arduino ([08](08-arduino.md)): IR remote or buttons → HA → lights; photoresistor → lights on when the room gets dark.
- Status light: Play lights flash red when a homelab service goes down.
