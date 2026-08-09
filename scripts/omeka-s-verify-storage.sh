#!/usr/bin/env sh

set -eu

readonly files=/var/www/omeka-s/files
mode="${1:---read-only}"

case "${mode}" in
  --read-only)
    test -r "${files}"
    test -w "${files}"
    echo 'storage writable'
    ;;
  --disposable)
    probe="${files}/.sitectl-verify-$$"
    cleanup() {
      rm -f -- "${probe}"
    }
    trap cleanup EXIT INT TERM
    printf '%s' sitectl-verify > "${probe}"
    test "$(cat "${probe}")" = sitectl-verify
    cleanup
    trap - EXIT INT TERM
    echo 'storage round trip complete'
    ;;
  *)
    echo "unsupported storage verification mode: ${mode}" >&2
    exit 64
    ;;
esac
