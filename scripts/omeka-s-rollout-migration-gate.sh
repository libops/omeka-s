#!/usr/bin/env sh

set -eu

result="$(curl --connect-timeout 2 --max-time 30 -sS -o /dev/null -w '%{http_code} %{redirect_url}' http://127.0.0.1/admin)" || {
  status="$?"
  echo "Unable to inspect Omeka S migration state (curl status ${status})" >&2
  exit "${status}"
}

code="${result%% *}"
redirect="${result#* }"

case "${code}" in
  200 | 301 | 302 | 303 | 307 | 308) ;;
  *)
    echo "Unexpected Omeka S admin response: ${code}" >&2
    exit 3
    ;;
esac

case "${redirect}" in
  */migrate | */migrate/)
    echo "ACTION REQUIRED: Omeka S requires its supported browser migration. Public Traefik remains stopped. Run sitectl port-forward 8080:omeka-s:80, open http://localhost:8080/admin, complete the migration, stop the forward, and rerun sitectl deploy --skip-git --no-pull. If this deploy selected a non-active context, pass the same --context NAME to both sitectl commands." >&2
    exit 10
    ;;
esac
