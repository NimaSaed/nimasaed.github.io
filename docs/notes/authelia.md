# **Authelia Deployment with Rootless Podman and Traefik**

This guide provides step-by-step instructions for deploying **Authelia** in a **Podman** pod with **Traefik** as the reverse proxy for authentication, including secure secret management and basic access control.

* **Pod Creation**: Creates a Podman pod named `auth` exposing port `9091` and attached to the `reverse_proxy` network.
* **Secret Management**: Uses `podman secret` to create and manage secrets for JWT, session, and storage encryption.
* **Authelia Deployment**: Runs Authelia in the pod with required secrets, environment variables, and Traefik labels for routing and forward authentication.
* **Authentication Test**: Deploys a `whoami` test container to validate the Authelia setup using Traefik middleware.
* **Configuration**: YAML configuration for access control (bypass, one-factor, two-factor) and session cookie policies.
* **User Database**: Defines users and groups using Argon2id hashed passwords for secure authentication.


## To create Pod

```bash
podman pod \
create \
--name auth \
--publish 9091:9091/tcp \
--network reverse_proxy
```


## To create secret

```bash
printf 'myjwtsecret' | podman secret create authelia_jwt_secret -
printf 'mysessionsecret' | podman secret create authelia_session_secret -
printf 'mystorageenckey' | podman secret create authelia_storage_encryption_key -
```

## To replace secret

```bash
printf "new" | podman secret create --replace secret_name -
```

## To create Container in a Pod

```bash
podman run \
--detach \
--label "io.containers.autoupdate=registry" \
--label "traefik.enable=true" \
--label traefik.http.routers.authelia.rule='host(`auth.example.com`)' \
--label "traefik.http.routers.authelia.entrypoints=websecure" \
--label "traefik.http.routers.authelia.tls.certresolver=namecheap" \
--label "traefik.http.routers.authelia.service=authelia" \
--label "traefik.http.services.authelia.loadbalancer.server.scheme=http" \
--label "traefik.http.services.authelia.loadbalancer.server.port=9091" \
--label "traefik.http.middlewares.authelia.forwardauth.address=http://host.docker.internal:9091/api/authz/forward-auth" \
--label "traefik.http.middlewares.authelia.forwardauth.trustforwardheader=true" \
--label "traefik.http.middlewares.authelia.forwardauth.authresponseheaders=remote-user,remote-groups,remote-email,remote-name" \
--name authelia \
--pod  auth \
--restart always \
--env tz=europe/amsterdam \
--env AUTHELIA_SERVER_ADDRESS='tcp://:9091' \
--env AUTHELIA_LOG_LEVEL=warn \
--env AUTHELIA_TOTP_ISSUER='auth.example.com' \
--env AUTHELIA_AUTHENTICATION_BACKEND_FILE_PATH='/config/users_database.yml' \
--env AUTHELIA_ACCESS_CONTROL_DEFAULT_POLICY='deny' \
--env AUTHELIA_REGULATION_MAX_RETRIES=3 \
--env AUTHELIA_REGULATION_FIND_TIME="2 minutes" \
--env AUTHELIA_REGULATION_BAN_TIME="5 minutes" \
--env AUTHELIA_STORAGE_LOCAL_PATH="/config/db.sqlite3" \
--env AUTHELIA_NOTIFIER_FILESYSTEM_FILENAME="/config/notification.txt" \
--secret authelia_jwt_secret,type=env,target=AUTHELIA_IDENTITY_VALIDATION_RESET_PASSWORD_JWT_SECRET \
--secret authelia_session_secret,type=env,target=AUTHELIA_SESSION_SECRET \
--secret authelia_storage_encryption_key,type=env,target=AUTHELIA_STORAGE_ENCRYPTION_KEY \
--volume $HOME/authelia:/config:z \
ghcr.io/authelia/authelia:latest
```


## To test the authentication

```bash
podman run \
--detach \
--label "io.containers.autoupdate=registry" \
--label "traefik.enable=true" \
--label traefik.http.routers.whoami.rule='Host(`whoami.example.com`)' \
--label "traefik.http.routers.whoami.entrypoints=websecure" \
--label "traefik.http.routers.whoami.tls.certresolver=namecheap" \
--label "traefik.http.routers.whoami.service=whoami" \
--label "traefik.http.services.whoami.loadbalancer.server.scheme=http" \
--label "traefik.http.services.whoami.loadbalancer.server.port=80" \
--label "traefik.http.routers.whoami.middlewares=authelia@docker" \
--network reverse_proxy \
--name whoami \
docker.io/library/nginx
```

## Configuration file

```yaml
---
access_control:
  rules:
    - domain:
      - 'public.example.com'
      policy: 'bypass'
    - domain:
      - 'subdomain1.example.com'
      - 'subdomain2.example.com'
      policy: 'one_factor'
    - domain:
      - 'secure.example.com'
      policy: 'two_factor'

session:
  # session secret is in env
  cookies:
    - name: 'authelia_session'
      domain: 'example.com'  # Should match whatever your root protected domain is
      authelia_url: 'https://auth.example.com'
      expiration: '1 hour'  # 1 hour
      inactivity: '5 minutes'  # 5 minutes
      default_redirection_url: 'https://home.example.com'
...
```

## Users database

```yaml
users:
    username:
        password: $argon2id$...
        displayname: user display name
        email: user@example.com
        groups:
            - admins
            - dev
        given_name: ""
        middle_name: ""
        family_name: ""
        nickname: ""
        gender: ""
        birthdate: ""
        website: ""
        profile: ""
        picture: ""
        zoneinfo: ""
        locale: ""
        phone_number: ""
        phone_extension: ""
        disabled: false
        address: null
        extra: {}
```
