#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"${FAKE_BROWSER_LOG:?}"

case "${1:-}" in
  --version)
    printf 'agent-browser 99.0.0\n'
    ;;
  skills)
    [[ "${2:-}" == 'get' ]] && [[ "${3:-}" == 'core' ]]
    printf 'mock core workflow\n'
    ;;
  doctor)
    [[ "${2:-}" == '--offline' ]]
    ;;
esac
