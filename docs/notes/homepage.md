# Deploy [homepage](https://gethomepage.dev/) using rootless podman

```bash
podman run \
--detach \
--label "io.containers.autoupdate=registry" \
--label "traefik.enable=true" \
--label traefik.http.routers.homepage.rule='Host(`home.example.com`)' \
--label "traefik.http.routers.homepage.entrypoints=websecure" \
--label "traefik.http.routers.homepage.tls.certresolver=namecheap" \
--label "traefik.http.routers.homepage.service=homepage" \
--label "traefik.http.services.homepage.loadbalancer.server.scheme=http" \
--label "traefik.http.services.homepage.loadbalancer.server.port=3000" \
--label "traefik.http.routers.homepage.middlewares=authelia@docker" \
--name homepage \
--pod  tools \
--env HOMEPAGE_ALLOWED_HOSTS=home.example.com \
--volume $HOME/homepage:/app/config:z \
ghcr.io/gethomepage/homepage:latest
```
