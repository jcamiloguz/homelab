# 10 · Desktop server (GPU node)

**Goal:** revive the old desktop as the homelab's second server — the Pi stays the always-on box, the desktop does the heavy/GPU work and sleeps when idle.

| Part | Spec |
|---|---|
| CPU | Ryzen 5 2600 (6c/12t, no iGPU) |
| RAM | 16 GB |
| GPU | GTX 1060 6 GB (Pascal) |
| Disk | NVMe SSD |

## Role split
| Pi 5 (always on, ~5 W) | Desktop (on demand, ~60–100 W idle) |
|---|---|
| Pi-hole, Tailscale, Home Assistant | Ollama (7–8B models on GPU) |
| Hub, Hermes Agent | Immich + ML (face/object recognition) |
| Wakes the desktop (Wake-on-LAN) | Frigate (camera detection), heavy builds, backups target |

## 1. Install
- **Ubuntu Server 24.04 LTS** — simplest path for NVIDIA drivers + Docker. (Proxmox later if VMs are needed; GPU passthrough adds complexity.)
- BIOS first: update it, enable **Wake-on-LAN**, set *Restore on AC power loss* as preferred, enable SVM if VMs are planned.
- Same hardening as the Pi → [01-os-setup.md](01-os-setup.md) (SSH keys only, ufw, unattended-upgrades).
- Docker → [02-docker.md](02-docker.md). Tailscale → [03-tailscale.md](03-tailscale.md) (`--ssh`, disable key expiry, tag `tag:server`).

## 2. NVIDIA
```bash
sudo ubuntu-drivers list              # pick the recommended -server driver
sudo ubuntu-drivers install
sudo reboot
nvidia-smi                            # GPU visible
```
Then the NVIDIA Container Toolkit so containers can use the GPU:
```bash
# follow NVIDIA's install guide for the apt repo, then:
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
docker run --rm --gpus all ubuntu nvidia-smi
```
> ⚠️ Pascal is end-of-life for new NVIDIA features: the **580 driver branch is the last** that supports it, and CUDA 13 dropped it. Stay on the 580 branch / CUDA 12 and check that each GPU app still supports compute capability 6.1 before relying on it.

## 3. First workload: Ollama
- Run Ollama in Docker with `--gpus all`, listening only on the tailnet.
- 6 GB VRAM fits ~7–8B models at Q4 (e.g. Llama 3.1 8B, Qwen 7B). Benchmark tokens/s and log it in the journal.
- Hermes Agent / Open WebUI on the Pi point at `http://<DESKTOP_HOST>.<TAILNET>:11434`, with a small local model on the Pi as fallback.

## 4. Sleep & wake
- Idle → `systemctl suspend` (or a script that suspends when Ollama/Immich are idle).
- Wake from the Pi: `wakeonlan <DESKTOP_MAC>` — the Pi is always on and on the same LAN. Can be a Home Assistant button or a Hermes tool.
- Note: Tailscale can't wake a sleeping machine — the wake packet must come from the LAN (the Pi).

## Verify
- `tailscale ssh <DESKTOP_HOST>` works from the Mac on another network.
- `nvidia-smi` inside a container shows the GTX 1060.
- Ollama answers from the Pi over the tailnet; GPU is used (`nvidia-smi` shows the process).
- Desktop suspends, and wakes from a Pi command.

## Open questions
- Measure real idle/load power (smart plug) → decide always-on vs. sleep.
- Extra HDDs for Immich/backups (the case has room — no NAS needed yet)?
- Proxmox later for VMs, or keep plain Docker?
