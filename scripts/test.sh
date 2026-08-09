#!/usr/bin/env bash

set -eou pipefail

bash scripts/sitectl-rollout-preflight.sh
./scripts/test-rollout-programs.sh
docker compose build --pull
docker compose run --rm init
docker compose up --remove-orphans --wait --wait-timeout "${COMPOSE_WAIT_TIMEOUT:-600}"

./scripts/test-runtime-programs.sh
curl -fsS "${SITE_URL:-http://localhost/}" >/dev/null
