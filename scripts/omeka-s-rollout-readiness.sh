#!/usr/bin/env sh

set -eu

started="$(date +%s)"
deadline=$((started + 600))

until test -f /installed && curl --connect-timeout 2 --max-time 5 -fsS http://127.0.0.1/status | grep -q pool; do
  now="$(date +%s)"
  if [ "${now}" -ge "${deadline}" ]; then
    echo "Omeka S did not become ready for migration inspection within 10 minutes" >&2
    exit 1
  fi
  sleep 2
done
