#!/usr/bin/env bash

set -eou pipefail

docker compose build --pull
./scripts/init-if-needed.sh
docker compose up --remove-orphans -d

curl -fsS "${SITE_URL:-http://localhost/}" >/dev/null
