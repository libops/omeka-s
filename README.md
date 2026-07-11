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

The `omeka-s` service builds this checkout on top of the app-versioned LibOps Omeka S image. Omeka S core and its application dependencies are already present in that image; this template image only adds the modules and themes owned by the downstream site. Local builds use the platform selected by the Docker CLI and do not push images.

Docker Compose derives the project name from the checkout directory, so independent forks do not share containers, networks, or named volumes by default. Set `COMPOSE_PROJECT_NAME` explicitly when a stable name is required.

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

Update the application base tag or pin that base by digest with [`sitectl image`](https://sitectl.libops.io/commands/image):

```bash
sitectl image set --tag omeka-s=4.2.1-php84
sitectl image set --build-arg omeka-s.BASE_IMAGE=libops/omeka-s:4.2.1-php84@sha256:...
```

The image tag starts with the Omeka S release and ends with the PHP flavor. Updating that base image and rebuilding the derived site image upgrades application core without copying core into the downstream repository. Back up the database and `omeka-s-files` volume before an application upgrade. After the new container starts, sign in at `/admin` and complete any database migration prompt; the upgrade is not complete until that succeeds.

Publish a domain, switch HTTP/TLS mode, configure Let's Encrypt, trust upstream proxies, or tune upload limits with the `ingress` component:

```bash
sitectl set ingress enabled --mode https-custom --domain omeka-s.localhost
sitectl set ingress enabled --mode https-letsencrypt --domain omeka-s.example.org --acme-email ops@example.org
sitectl set ingress enabled --trusted-ip 203.0.113.10/32 --max-upload-size 2G --upload-timeout 10m
```

`sitectl set` applies the requested component change immediately. Use `sitectl converge` when you want an interactive review of the complete component state.

The ingress component writes `INGRESS_HOSTNAMES` as comma-separated hostnames and `INGRESS_SCHEME` as `http` or `https` into the app container. Runtime config is rendered from those values during container startup, so generated sites should not carry separate app URL env vars for the same public route.

See the [Omeka S sitectl plugin docs](https://sitectl.libops.io/plugins/omeka-s) for lifecycle operations, API helpers, resource shortcuts, and module maintenance.

## Makefile

The Makefile is intentionally small. It only keeps template-specific targets that are not core sitectl operations:

```bash
sitectl deploy
make test
make lint
```

Use `sitectl compose ...` and `sitectl set ...` directly for normal stack operations.

## Template notes

- `traefik` is the only published ingress.
- `omeka-s` is a small downstream customization image based on the app-versioned LibOps Omeka S image.
- `mariadb` stores application data.
- `omeka-s-files` persists uploaded files.
- Secrets are generated into `./secrets/`.

Application core and its Composer dependencies belong to the base image. Downstream code belongs under `modules/` and `themes/`; do not copy or bind-mount the complete Omeka S application tree over the image.

Rebuild and redeploy the derived site image after changing a checked-in module or theme. These directories are intentionally not bind-mounted over the base image because doing so would hide modules and themes shipped by Omeka S.

Only MariaDB and the one-shot `database-init` service receive `DB_ROOT_PASSWORD`. The initializer idempotently creates the database and scoped user before Omeka S starts; the long-running app receives only `OMEKA_S_DB_PASSWORD` as `DB_PASSWORD`.

PHP `mail()` is routed through `msmtp`. By default, Omeka S relays through the Docker host so production delivery can use the host MTA and LibOps relay path.

## License

The Docker Compose template and LibOps-specific setup in this repository are licensed under the MIT License. Omeka S is licensed separately under the GNU General Public License v3; see `LICENSE.omeka-s`.
