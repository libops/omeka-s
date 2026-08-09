#!/usr/bin/env bash

set -euo pipefail

docker compose exec -T omeka-s /usr/local/bin/sitectl-omeka-s-rollout-readiness
docker compose exec -T omeka-s /usr/local/bin/sitectl-omeka-s-rollout-migration-gate

version="$(docker compose exec -T omeka-s php /usr/local/share/libops/sitectl-omeka-s-version.php)"
if [ "${version}" != "4.2.1" ]; then
  echo "Unexpected Omeka S version from checked-in probe: ${version}" >&2
  exit 1
fi

docker compose exec -T omeka-s /usr/local/bin/sitectl-omeka-s-verify-database >/dev/null
docker compose exec -T omeka-s s6-setuidgid nginx /usr/local/bin/sitectl-omeka-s-verify-storage --read-only >/dev/null
