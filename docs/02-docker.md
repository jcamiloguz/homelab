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
