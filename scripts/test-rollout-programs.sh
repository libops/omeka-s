#!/usr/bin/env bash

set -euo pipefail

readonly repository_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
readonly fixture_bin="${repository_root}/scripts/testdata/bin"
readonly migration_gate="${repository_root}/scripts/omeka-s-rollout-migration-gate.sh"
readonly readiness="${repository_root}/scripts/omeka-s-rollout-readiness.sh"

assert_gate() {
  local name="$1"
  local body="$2"
  local curl_exit="$3"
  local expected_exit="$4"
  local expected_output="$5"
  local output
  local status

  set +e
  output="$(PATH="${fixture_bin}:${PATH}" FAKE_CURL_BODY="${body}" FAKE_CURL_EXIT="${curl_exit}" "${migration_gate}" 2>&1)"
  status="$?"
  set -e

  if [ "${status}" -ne "${expected_exit}" ]; then
    echo "${name}: migration gate exited ${status}, expected ${expected_exit}: ${output}" >&2
    exit 1
  fi
  if [ -n "${expected_output}" ] && [[ "${output}" != *"${expected_output}"* ]]; then
    echo "${name}: migration gate output omitted ${expected_output}: ${output}" >&2
    exit 1
  fi
}

assert_gate current '302 http://127.0.0.1/admin/login' 0 0 ''
assert_gate migration-required '302 http://127.0.0.1/migrate' 0 10 'ACTION REQUIRED'
assert_gate unexpected-response '500 ' 0 3 'Unexpected Omeka S admin response'
assert_gate curl-failure '' 28 28 'curl status 28'

temporary_directory="$(mktemp -d)"
trap 'rm -rf -- "${temporary_directory}"' EXIT

set +e
readiness_output="$(PATH="${fixture_bin}:${PATH}" FAKE_DATE_STATE="${temporary_directory}/date.state" "${readiness}" 2>&1)"
readiness_status="$?"
set -e

if [ "${readiness_status}" -ne 1 ] || [[ "${readiness_output}" != *'within 10 minutes'* ]]; then
  echo "readiness did not enforce its wall-clock deadline: exit=${readiness_status} output=${readiness_output}" >&2
  exit 1
fi
