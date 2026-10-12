# 02 · Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER      # log out / in afterwards
docker run --rm hello-world
docker compose version
```

Data directory for all services (outside the repo):
```bash
sudo mkdir -p /srv/homelab && sudo chown $USER:$USER /srv/homelab
```

Convention: each service lives in `services/<name>/compose.yml`, reads `.env` from the repo root, and stores state in `${DATA_DIR}/<name>/`.

## Gotcha: memory limits are ignored by default
Pi OS boots with `cgroup_disable=memory`, so `mem_limit` in compose is silently dropped (`Your kernel does not support memory limit capabilities`). Enable it once, reboot, then recreate containers that were created without it:
```bash
sudo sed -i '1 s/$/ cgroup_enable=memory/' /boot/firmware/cmdline.txt && sudo reboot
docker compose -f services/<name>/compose.yml --env-file .env up -d --force-recreate
docker stats --no-stream      # LIMIT column shows the cap, not the full RAM
```
