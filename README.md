# Omeka S Docker Template

The Omeka S Docker Template gives you a Docker Compose repository for running [Omeka S](https://omeka.org/s/). It includes Traefik, MariaDB, and the LibOps Omeka S PHP/nginx image, and is designed to be managed with [`sitectl-omeka-s`](https://github.com/libops/sitectl-omeka-s).

Docs:

- [Managed application architecture](https://sitectl.libops.io/apps)
- [Omeka S sitectl plugin](https://sitectl.libops.io/plugins/omeka-s)

## Requirements

- [sitectl](https://sitectl.libops.io/install) installed on the host that will run the site.
- [`sitectl-omeka-s`](https://github.com/libops/sitectl-omeka-s) installed for Omeka S create, validation, healthcheck, and helper commands.
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

## Local image build

The `omeka-s` service builds this checkout on top of the LibOps Omeka S base image. The Dockerfile downloads the pinned Omeka S release, installs Composer dependencies, then copies local modules and themes so Docker can reuse dependency layers when only site customizations change. Local builds use the platform selected by the Docker CLI and do not push images.

## Basic Operations

Run these from the generated checkout, or add `--context <name>` when operating from elsewhere.

Start or update the stack with [`sitectl compose`](https://sitectl.libops.io/commands/compose):

```bash
sitectl compose up --remove-orphans -d
```

Check the site and context configuration with [`sitectl healthcheck`](https://sitectl.libops.io/commands/healthcheck) and [`sitectl validate`](https://sitectl.libops.io/commands/validate):

```bash
sitectl healthcheck
sitectl validate
```

Update image tags or pin a full image reference with [`sitectl image`](https://sitectl.libops.io/commands/image):

```bash
sitectl image set --tag omeka-s=nginx-1.30.3-php84
sitectl image set --image omeka-s=libops/omeka-s:nginx-1.30.3-php84@sha256:...
```

Enable local development bind mounts with [`sitectl set`](https://sitectl.libops.io/commands/set), then apply the component change with [`sitectl converge`](https://sitectl.libops.io/commands/converge):

```bash
sitectl set dev-mode enabled
sitectl converge
```

Switch TLS modes with the [Traefik service commands](https://sitectl.libops.io/plugins/traefik):

```bash
sitectl traefik tls mkcert --domain omeka-s.localhost
sitectl traefik tls letsencrypt --email ops@example.org
```

Trust an upstream load balancer or reverse proxy with [`sitectl set`](https://sitectl.libops.io/commands/set), then apply it with [`sitectl converge`](https://sitectl.libops.io/commands/converge):

```bash
sitectl set reverse-proxy enabled --trusted-ip 203.0.113.10/32
sitectl converge
```

Raise upload limits with [`sitectl set`](https://sitectl.libops.io/commands/set), then apply them with [`sitectl converge`](https://sitectl.libops.io/commands/converge):

```bash
sitectl set upload-limits enabled --max-upload-size 2G --upload-timeout 10m
sitectl converge
```

See the [Omeka S sitectl plugin docs](https://sitectl.libops.io/plugins/omeka-s) for lifecycle operations, API helpers, resource shortcuts, and module maintenance.

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

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. Omeka S is licensed separately under the GNU General Public License v3; see `LICENSE.omeka-s`.
