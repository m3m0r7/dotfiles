#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="${SCRIPT_DIR}/../references"
STATE_DIR="${PROJECT_ROOT}/.hermes-prj-states"
TMP_DIR="${STATE_DIR}/tmp"

install_if_missing() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$dst" ]; then
    cp "$src" "$dst"
  fi
}

mkdir -p "$TMP_DIR"

install_if_missing "${REF_DIR}/state-template.md" "${STATE_DIR}/STATE.md"
install_if_missing "${REF_DIR}/programming-known-template.md" "${STATE_DIR}/PROGRAMMING_KNOWN.md"
install_if_missing "${REF_DIR}/ci-template.md" "${STATE_DIR}/CI.md"

printf 'Initialized hermes state in %s\n' "$STATE_DIR"
