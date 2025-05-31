
## To Enable Rootless Podman Socket

```bash
systemctl --user enable --now podman.socket
```

## To Create a Network

```bash
podman network \
create \
reverse_proxy
```

## To Create a Pod

```bash
podman pod \
create \
--name reverse_proxy \
--network reverse_proxy \
--publish 80:80/tcp \
--publish 443:443/tcp \
--publish 8080:8080/tcp \
--dns "1.1.1.1"
```

## To Create a Traefik Container

```bash
podman run \
--detach \
--label "io.containers.autoupdate=registry" \
--name traefik \
--pod reverse_proxy \
--security-opt label=type:container_runtime_t \
--volume /run/user/`id -u`/podman/podman.sock:/var/run/docker.sock:ro,Z \
--volume $HOME/traefik/acme.json:/acme.json:Z \
--volume $HOME/traefik/home.yml:/home.yml:ro,Z \
--restart always \
--env "TRAEFIK_LOG_LEVEL=DEBUG" \
--env "TRAEFIK_PROVIDERS_DOCKER=true" \
--env "TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT=false" \
--env "TRAEFIK_API_INSECURE=true" \
--env "TRAEFIK_API=true" \
--env "TRAEFIK_API_DASHBOARD=true" \
--env "TRAEFIK_ENTRYPOINTS_WEB_ADDRESS=:80" \
--env "TRAEFIK_ENTRYPOINTS_WEBSECURE_ADDRESS=:443" \
--env "TRAEFIK_ENTRYPOINTS_WEB_HTTP_REDIRECTIONS_ENTRYPOINT_TO=websecure" \
--env "TRAEFIK_ENTRYPOINTS_WEB_HTTP_REDIRECTIONS_ENTRYPOINT_SCHEME=https" \
--env "TRAEFIK_CERTIFICATESRESOLVERS_NAMECHEAP_ACME_DNSCHALLENGE=true" \
--env "TRAEFIK_CERTIFICATESRESOLVERS_NAMECHEAP_ACME_DNSCHALLENGE_PROVIDER=namecheap" \
--env "TRAEFIK_CERTIFICATESRESOLVERS_NAMECHEAP_ACME_DNSCHALLENGE_RESOLVERS=1.1.1.1:53" \
--env "TRAEFIK_CERTIFICATESRESOLVERS_NAMECHEAP_ACME_STORAGE=/acme.json" \
--env "TRAEFIK_PROVIDERS_FILE_FILENAME=/home.yml" \
--env "TRAEFIK_PROVIDERS_FILE_WATCH=true" \
--env "TRAEFIK_SERVERSTRANSPORT_INSECURESKIPVERIFY=true" \
--secret namecheap_email,type=env,target=TRAEFIK_CERTIFICATESRESOLVERS_NAME_ACME_EMAIL \
--secret namecheap_api_user,type=env,target=NAMECHEAP_API_USER \
--secret namecheap_api_key,type=env,target=NAMECHEAP_API_KEY \
docker.io/library/traefik
```


## To Create a Nginx Container for Testing

```bash
podman run \
--detach \
--label "traefik.enable=true" \
--label traefik.http.routers.whoami.rule='Host(`nginx.example.com`)' \
--label "traefik.http.routers.whoami.entrypoints=websecure" \
--label "traefik.http.routers.whoami.tls.certresolver=namecheap" \
--network reverse_proxy \
--name whoami \
docker.io/library/nginx
```

## The configuration file

```yaml
http:
  routers:
    home:
      rule: "Host(`server.example.com`)"
      service: cockpit-service
      entryPoints:
        - websecure
      tls:
        certResolver: namecheap
    traefik:
      rule: "Host(`traefik.example.com`)"
      service: traefik-service
      entryPoints:
        - websecure
      tls:
        certResolver: namecheap
  services:
    cockpit-service:
      loadBalancer:
        servers:
          - url: "https://host.docker.internal:9090"
    traefik-service:
      loadBalancer:
        servers:
          - url: "http://host.docker.internal:8080"
```
