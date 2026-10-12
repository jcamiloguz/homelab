# 01 · OS setup & hardening

**Goal:** Raspberry Pi OS Lite (64-bit) booting from NVMe, reachable only via SSH keys, auto-updating.

## 1. Flash
Easiest path: put the NVMe in a USB enclosure and flash it directly from the Mac with **Raspberry Pi Imager**:
- OS: *Raspberry Pi OS Lite (64-bit)*
- Settings (⚙️): hostname `<PI_HOST>`, user `<USER>`, **enable SSH with public-key only**, paste your `~/.ssh/id_ed25519.pub`, set locale/timezone. Wi-Fi optional (prefer Ethernet).

Alternative: boot from microSD, then use Imager on the Pi (`sudo apt install rpi-imager`) or `SD Card Copier` to write to NVMe.

## 2. Boot from NVMe
If the Pi doesn't boot from NVMe on its own (boot from SD once):
```bash
sudo rpi-eeprom-update -a            # latest bootloader
sudo rpi-eeprom-config --edit        # set: BOOT_ORDER=0xf416  (NVMe → SD → USB)
```
Optional PCIe Gen 3 — add to `/boot/firmware/config.txt`:
```ini
dtparam=pciex1_gen=3
```
Reboot, remove SD card, verify:
```bash
lsblk                     # root (/) should be on nvme0n1p2
```

## 3. First login & updates
```bash
ssh <USER>@<PI_HOST>.local
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y git curl htop vim unattended-upgrades ufw
sudo dpkg-reconfigure -plow unattended-upgrades
```

## 4. SSH hardening
`/etc/ssh/sshd_config.d/10-hardening.conf`:
```
PasswordAuthentication no
PermitRootLogin no
KbdInteractiveAuthentication no
```
```bash
sudo systemctl restart ssh
```

## 5. Firewall
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp   # adjust to your LAN range
sudo ufw allow 53                                              # Pi-hole DNS
sudo ufw allow in on tailscale0
sudo ufw enable
```
> ⚠️ Docker publishes ports by editing iptables directly and **bypasses ufw**. Only publish what you need, or bind to specific interfaces.

## 6. Static IP
Reserve the Pi's IP in your router's DHCP settings (simplest), so Pi-hole has a stable address.

## Verify
- `ssh` with password fails, with key works
- `sudo ufw status verbose`
- `vcgencmd measure_temp` and `vcgencmd get_throttled` (should be `0x0`)

## Gotchas
- Pi OS keeps logs in RAM only (`40-rpi-volatile-storage.conf`) → after a crash there's nothing to read. Make them persistent with a cap:
  `printf '[Journal]\nStorage=persistent\nSystemMaxUse=200M\n' | sudo tee /etc/systemd/journald.conf.d/90-persistent.conf && sudo systemctl restart systemd-journald && sudo journalctl --flush`
- Hardware watchdog (reboot if the Pi hangs): `printf '[Manager]\nRuntimeWatchdogSec=15\nRebootWatchdogSec=2min\n' | sudo tee /etc/systemd/system.conf.d/90-watchdog.conf && sudo systemctl daemon-reexec`
- Ghostty terminal: `Error opening terminal: xterm-ghostty` → `TERM=xterm-256color`, or Ghostty config `shell-integration-features = ssh-env`.
- Pi OS Lite ships without `git` → `sudo apt install -y git` before cloning this repo.
- `setlocale: cannot change locale (en_US.UTF-8)` on SSH from a Mac → the Mac forwards its locale; generate it on the Pi: `sudo sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && sudo locale-gen`.
