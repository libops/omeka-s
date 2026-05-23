#!/usr/bin/env bash

set -eou pipefail

curl -fsS "http://localhost:${HOST_INSECURE_PORT:-80}/" >/dev/null

