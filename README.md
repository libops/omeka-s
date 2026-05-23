# Omeka S Docker Template

LibOps-owned Docker Compose template for Omeka S.

## Quick Start

```bash
make up
```

The site is served through Traefik at `http://localhost`. The first boot creates the database and submits the Omeka S installer automatically.

`make up` runs `scripts/init-if-needed.sh`, which inspects the rendered Docker Compose config and only runs the `init` service when required secrets or named volumes are missing.

Default admin values:

- Email: `admin@example.com`
- Password: `./secrets/OMEKA_S_ADMIN_PASSWORD`
- Display name: `Administrator`

## Layout

- `docker-compose.yaml` defines the production-style stack.
- `init` generates file-backed secrets before the stack starts.
- `traefik` is the only HTTP ingress.
- `omeka-s` is built from this repository and based on the Islandora Omeka S PHP/nginx image.
- `mariadb` uses the Islandora MariaDB image.
- `omeka-s-files` persists uploaded files.

`docker-compose.yaml` is the production-shaped default. Local development changes should be copied from `docker-compose.override-example.yaml` to `docker-compose.override.yaml`; the example only exposes MariaDB for debugging.

## SMTP

PHP `mail()` is routed through `msmtp`. By default, Omeka S relays through `${LIBOPS_SMTP_HOST:-host.docker.internal}:${LIBOPS_SMTP_PORT:-25}` so production delivery is handled by the host MTA and LibOps relay path. The override example adds Mailpit and points the app at `mailpit:1025` for local testing.

## Rollouts

`make rollout` runs `scripts/rollout.sh`, which checks out the requested git ref when provided, pulls/builds images, runs the init gate, and converges the Compose stack. LibOps API registrations should use `./scripts/rollout.sh` for this template's `RolloutCmd`.

## Updates

Renovate tracks:

- Omeka S GitHub releases through the Dockerfile build argument.
- Docker images in Compose and Dockerfile.
- Shared LibOps Renovate defaults through `github>libops/renovate-config`.
