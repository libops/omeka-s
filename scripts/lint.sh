#!/usr/bin/env bash

set -euo pipefail

service="${COMPOSE_SERVICE:-omeka-s}"
image="$(docker compose config --format json | jq -r --arg service "${service}" '.services[$service].image // empty')"

if [ -z "${image}" ]; then
  echo "Compose service ${service} does not define an image" >&2
  exit 1
fi

case "${image}" in
  *libops*) ;;
  *)
    echo "Expected ${service} image to be a libops image, got ${image}" >&2
    exit 1
    ;;
esac

if command -v hadolint >/dev/null 2>&1; then
  find . -name Dockerfile -exec hadolint {} +
else
  echo "hadolint not found, skipping Dockerfile validation"
fi

if command -v json5 >/dev/null 2>&1 && [ -f renovate.json5 ]; then
  json5 --validate renovate.json5 >/dev/null
else
  echo "json5 not found or renovate.json5 missing, skipping renovate validation"
fi

if command -v shellcheck >/dev/null 2>&1; then
  find scripts -name "*.sh" -exec shellcheck {} +
else
  find scripts -name "*.sh" -exec bash -n {} +
fi

docker compose build --pull "${service}"

docker run --rm \
  --volume "${PWD}:/workspace:ro" \
  --workdir /workspace \
  --entrypoint sh \
  "${image}" \
  -lc '
    set -eu

    paths=""
    for dir in modules themes rootfs; do
      if [ -d "${dir}" ]; then
        paths="${paths} ${dir}"
      fi
    done

    if [ -z "${paths}" ] || ! find ${paths} -type f -name "*.php" | grep -q .; then
      echo "No custom Omeka S PHP files found; skipping PHP lint."
      exit 0
    fi

    find ${paths} -type f -name "*.php" -exec php -l {} \;
  '
