#!/usr/bin/env sh

set -eu

found_php=0
for directory in modules themes rootfs; do
  if [ -d "${directory}" ] && find "${directory}" -type f -name '*.php' -print -quit | grep -q .; then
    found_php=1
    break
  fi
done

if [ "${found_php}" -eq 0 ]; then
  echo 'No custom Omeka S PHP files found; skipping PHP lint.'
  exit 0
fi

for directory in modules themes rootfs; do
  if [ -d "${directory}" ]; then
    find "${directory}" -type f -name '*.php' -exec php -l {} \;
  fi
done
