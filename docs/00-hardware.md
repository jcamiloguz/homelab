# 00 · Hardware

| Part | Notes |
|---|---|
| Raspberry Pi 5 (8 GB) | Enough for small local LLMs (1–3B) |
| M.2 HAT+ / NVMe base | PCIe x1; Gen 3 can be enabled (unofficial but common) |
| NVMe SSD | 256 GB+; check compatibility lists (some Phison/Sabrent quirks) |
| Official 27 W USB-C PSU | Under-powering causes NVMe/USB instability |
| Active cooler | Required for sustained AI workloads |
| microSD (optional) | Only for first boot / rescue |
| Arduino Uno R3 starter kit | Physical layer via USB serial → see [08-arduino.md](08-arduino.md) |
| Mac laptop | Dev machine + tailnet client |
| ESP32 (soon) | Wi-Fi sensors / Bluetooth proxy via ESPHome |
| 2× Philips Hue Play (no Bridge) | Controlled over Bluetooth → see [09-smart-home.md](09-smart-home.md) |
| Old desktop (to revive): Ryzen 5 2600, 16 GB, GTX 1060 6 GB, NVMe | Second server (Ubuntu) for GPU work → see [10-desktop-server.md](10-desktop-server.md) |

## Notes / findings
- _Fill in during setup: exact SSD model, temps under load, power draw._
