# Buying roadmap

Rule: **buy when the project that needs it starts** — not before. Log every purchase in the [journal](journal/). Prices are rough USD.

**Already owned:** Pi 5 (8 GB), Mac laptop, Arduino Uno R3 kit, 2× Hue Play, old desktop (Ryzen 5 2600, 16 GB, GTX 1060 6 GB, NVMe → [10](10-desktop-server.md)).

## Phase 0 · Pi essentials (now, if not owned yet)
- [ ] NVMe SSD 256–512 GB + M.2 HAT — ~$50–70
- [ ] Official 27 W USB-C PSU — ~$12
- [ ] Active cooler — ~$5
- [ ] Ethernet cable — ~$5

## Phase 1 · Protect your data (month 1, ~$75)
- [ ] ⭐ External USB SSD/HDD 1–2 TB for restic backups — ~$60 *(before real data goes into the Hub)*
- [ ] ESP32 DevKit 3-pack, USB-C — ~$15

## Phase 2 · Better sensors (months 1–2, ~$30)
- [ ] BME280 / SHT31 sensors ×2–3 — ~$10
- [ ] Breadboard, jumpers, 3.3 V↔5 V level shifter — ~$10
- [ ] Good USB-C data cables — ~$10

## Phase 3 · Reliability (months 2–4, ~$80–120)
- [ ] ⭐ Small UPS for Pi + router — ~$60–100
- [ ] Shelly Plug (power-cycle + measure the desktop's power draw) — ~$20

## Phase 4 · Smart home growth (months 3–6, only if needed)
- [ ] Zigbee dongle (SONOFF ZBDongle-E) — ~$25 · *if Hue over Bluetooth is flaky*
- [ ] Aqara/IKEA door, motion, temp sensors — ~$10–20 each · *after the dongle*
- [ ] Home Assistant Voice PE — ~$59 · *for voice → HA / Hermes*
- [ ] Shelly relays — ~$15–25 · *for real lamps/appliances*

## Phase 5 · Storage (months 6–12)
- [ ] 1–2 HDDs for the desktop (Immich, backups) — ~$60–100 each · *when Immich starts*
- [ ] Offsite backup: Backblaze B2 (~$6/TB/mo) *or* Pi Zero 2 W + disk at family's house (~$80)

## Phase 6 · Later / optional
- [ ] Camera(s) for Frigate on the desktop's GPU — ~$25–50 each
- [ ] Desktop upgrades if it becomes the main AI box: 32 GB RAM (~$50), used GPU with more VRAM (e.g. RTX 3060 12 GB) for bigger models and current CUDA support

## ❌ Not buying
- **Mini PC / second server** — the desktop covers it.
- **Raspberry Pi AI HAT** — the GTX 1060 does vision/LLM work better.
- **Pi 5 16 GB** — LLMs run on the desktop/Mac instead.
- **Hue Bridge** — only for TV/PC sync.
- **Google Coral TPU** — outdated.
- **Cheap relay modules for mains** — use Shelly.
- **NAS** — the desktop's drive bays come first.

**Essentials (phases 1–3): ~$200** over 3–4 months, mostly reliability.
