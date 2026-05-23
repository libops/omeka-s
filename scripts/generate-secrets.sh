#!/usr/bin/env bash

set -eou pipefail

readonly CHARACTERS='[A-Za-z0-9]'
readonly LENGTH=32

yq -r '.secrets[].file' docker-compose.yaml | uniq | while read -r SECRET; do
  if [ ! -f "${SECRET}" ]; then
    echo "Creating: ${SECRET}" >&2
    DIR=$(dirname "${SECRET}")
    mkdir -p "$DIR"
    (grep -ao "${CHARACTERS}" < /dev/urandom || true) | head "-${LENGTH}" | tr -d '\n' > "${SECRET}"
  fi
done

