#!/usr/bin/env bash

set -eou pipefail

docker compose build --pull
docker compose run --rm init
docker compose up --remove-orphans -d

curl -fsS "${SITE_URL:-http://localhost/}" >/dev/null
