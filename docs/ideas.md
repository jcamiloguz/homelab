# Ideas backlog

Brain dump of experiments. Promote to a numbered doc when started.

## Infra
- [ ] Monitoring: Uptime Kuma, Beszel or Netdata
- [ ] Backups: restic → external drive + offsite
- [ ] Updates: Watchtower (auto) or Renovate (PRs to this repo)
- [ ] `scripts/bootstrap.sh` — idempotent host setup (Ansible later?)

## AI
- [ ] Hermes Agent with ChatGPT account → [06](06-hermes-agent.md)
- [ ] Ollama + small local models (1–3B), benchmark tokens/s on Pi 5
- [ ] Open WebUI as chat front-end
- [ ] n8n automations triggered by the agent
- [ ] Voice assistant (Whisper + Piper) — probably too heavy, test it

## Apps
- [ ] Hub (own repo) → [07](07-hub.md)
- [ ] Home Assistant → [09](09-smart-home.md) (Hue Play over Bluetooth)
- [ ] Vaultwarden (passwords)
- [ ] Immich (photos) — needs more storage
- [ ] Syncthing

## Arduino / IoT
- [ ] Arduino Uno R3 as the physical layer (USB serial → MQTT bridge) → [08](08-arduino.md)
- [ ] `arduino-cli` on the Pi — flash sketches remotely over Tailscale
- [ ] Mosquitto (MQTT broker) as the shared message bus
- [ ] RGB LED service-status light + 16×2 LCD homelab dashboard
- [ ] Room sensors (temp/humidity/light) → Hub Health module
- [ ] Physical buttons / IR remote → agent & Hub actions
- [ ] ESP32 + ESPHome: Wi-Fi sensors + Bluetooth proxy for Home Assistant
