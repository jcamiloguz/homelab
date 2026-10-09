# 08 · Arduino (idea)

**Goal:** use an Arduino Uno R3 (starter kit) as the homelab's physical layer — sensors in, lights/buttons/displays out — with the Pi as the brain and Tailscale for remote access.

## Architecture
The Uno has no network, so it talks to the Pi over **USB serial**; the Pi bridges it to everything else.
```
sensors / LEDs ──► Arduino Uno ──USB serial──► Pi bridge ──► MQTT (Mosquitto)
                                                               │
                         Hub · Home Assistant · n8n · Hermes Agent
                                                               ▲
                                              phone, anywhere (Tailscale)
```
- **Arduino:** reads sensors, prints one JSON line per reading (`{"temp":22.4,"light":310}`), listens for commands (`LED:red`).
- **Bridge:** small service reading `/dev/arduino`, publishing to MQTT and forwarding commands back.
- **Consumers:** anything that speaks MQTT.

## Step 1 — flash remotely
```bash
# on the Pi
curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
arduino-cli core install arduino:avr
arduino-cli board list                          # find the port
arduino-cli compile --fqbn arduino:avr:uno sketches/<name>
arduino-cli upload  --fqbn arduino:avr:uno -p /dev/arduino sketches/<name>
```
From the laptop, anywhere: `tailscale ssh <PI_HOST>` → compile/upload. No need to be home.

## Step 2 — stable device name
udev rule so the port doesn't jump between `ttyACM0`/`ttyACM1`:
```
# /etc/udev/rules.d/99-arduino.rules
SUBSYSTEM=="tty", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0043", SYMLINK+="arduino"
```
Check IDs with `udevadm info -a -n /dev/ttyACM0` (clone boards often use a CH340, vendor `1a86`).

## Step 3 — serial → MQTT bridge
- Mosquitto in Docker (`services/mqtt/`), bound to LAN + tailnet only.
- Bridge container gets the port via `devices: ["/dev/arduino:/dev/arduino"]`.

## Project ideas
**Sensors → homelab**
- ⭐ Room temp/humidity (DHT11) → charts + Health module (sleep vs. room temp)
- Photoresistor → auto-log lights off/on (sleep tracking)
- Ultrasonic → desk presence / focus-time tracker
- PIR (if in kit) → motion log, "someone's home" alert while away

**Homelab → physical output**
- ⭐ RGB LED status light: green = all services up, red = Uptime Kuma alert
- 16×2 LCD: ads blocked today, Pi temp, tailnet devices online, monthly spend
- Buzzer on backup failure / Pi overheating
- Servo as an analog gauge (CPU load, budget used)

**Physical input → actions**
- ⭐ Buttons → Hermes/Hub actions ("add milk", "log water", "log workout")
- IR remote → pause Pi-hole 5 min from the couch
- Potentiometer → quick mood/energy 1–10 for the Health module

**AI**
- Hermes tool `read_room_sensors()` — "is my room too hot?" from the phone
- Hermes drives outputs — desk LED turns red 5 min before a meeting

## Safety & gotchas
- **USB, not GPIO.** Uno is 5 V, Pi GPIO is 3.3 V — direct UART without a level shifter can kill the Pi.
- **Relays:** low-voltage loads only (LED strips, 5 V fan). No mains with starter-kit relays.
- Opening the serial port resets the Uno — the bridge should wait ~2 s before sending commands.

## Open questions
- Which kit exactly (official vs. Elegoo)? → list parts in [00-hardware.md](00-hardware.md)
- Bridge language: Python (`pyserial` + `paho-mqtt`) or TypeScript (`serialport` + `mqtt`) to match the Hub?
- Home Assistant as the hub, or keep it all in the Hub?
- Upgrade path: ESP32 + ESPHome (Wi-Fi sensors around the house → Home Assistant on the Pi; the Pi provides tailnet access).
