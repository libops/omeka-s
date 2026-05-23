#!/usr/bin/env bash

set -eou pipefail

docker compose build --pull
./scripts/init-if-needed.sh
docker compose up --remove-orphans -d

curl -fsS "http://localhost:${HOST_INSECURE_PORT:-80}/" >/dev/null
