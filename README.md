# Omeka S Docker Template

LibOps Docker Compose template for running [Omeka S](https://omeka.org/s/) with Traefik, MariaDB, and the LibOps Omeka S PHP/nginx image.

## Requirements

- `sitectl` installed on the host that will run the site.
- Docker with the Compose v2 plugin installed on the same host.

## Quick start

Create a new Omeka S site from this template:

```bash
sitectl create omeka-s/default \
  --template-repo https://github.com/libops/omeka-s \
  --path ./my-omeka-s-site \
  --type local \
  --checkout-source template \
  --default-context
```

The site is served through Traefik at `http://localhost`. The first boot creates the database and submits the Omeka S installer automatically. The default admin password is generated in `./secrets/OMEKA_S_ADMIN_PASSWORD`.

## Basic operations with sitectl

Run these from the generated checkout, or add `--context <name>` when operating from elsewhere.

```bash
# Start or update the Compose stack
sitectl compose up --remove-orphans -d

# Check the site and context configuration
sitectl healthcheck
sitectl validate

# Update image tags or pin a full image reference
sitectl image set --tag omeka-s=nginx-1.30.3-php84
sitectl image set --image omeka-s=libops/omeka-s:nginx-1.30.3-php84@sha256:...

# Enable local development bind mounts
sitectl set dev-mode enabled
sitectl converge

# Switch TLS modes
sitectl traefik tls mkcert --domain omeka-s.localhost
sitectl traefik tls letsencrypt --email ops@example.org

# Trust an upstream load balancer or reverse proxy
sitectl set reverse-proxy enabled --trusted-ip 203.0.113.10/32
sitectl converge

# Raise upload limits for larger media
sitectl set upload-limits enabled --max-upload-size 2G --upload-timeout 10m
sitectl converge
```

See the [Omeka S sitectl plugin docs](https://github.com/libops/sitectl-docs/blob/main/plugins/omeka-s.mdx) for lifecycle operations, API helpers, resource shortcuts, and module maintenance.

## Makefile

The Makefile is intentionally small. It only keeps template-specific targets that are not core sitectl operations:

```bash
make rollout
make test
make lint
```

Use `sitectl compose ...`, `sitectl traefik ...`, and `sitectl set ...` directly for normal stack operations.

## Template notes

- `traefik` is the only published ingress.
- `omeka-s` is built from this repository and based on the LibOps Omeka S PHP/nginx image.
- `mariadb` stores application data.
- `omeka-s-files` persists uploaded files.
- Secrets are generated into `./secrets/`.

PHP `mail()` is routed through `msmtp`. By default, Omeka S relays through the Docker host so production delivery can use the host MTA and LibOps relay path.
