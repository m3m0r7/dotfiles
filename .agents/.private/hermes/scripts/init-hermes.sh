#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="${SCRIPT_DIR}/../references"
STATE_DIR="${PROJECT_ROOT}/.hermes-prj-states"
TMP_ROOT_DIR="${STATE_DIR}/tmp"
BRANCH_STATE_ROOT_DIR="${STATE_DIR}/states"

current_branch_name() {
  if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || true
  fi
}

sanitize_branch_name() {
  local raw="${1:-detached-head}"

  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  raw="$(printf '%s' "$raw" | sed -E 's#[^a-z0-9._-]+#-#g; s#-+#-#g; s#(^[-.]+|[-.]+$)##g')"

  if [ -z "$raw" ]; then
    raw="detached-head"
  fi

  printf '%s' "$raw"
}

install_if_missing() {
  local src="$1"
  local dst="$2"

  if [ ! -e "$dst" ]; then
    cp "$src" "$dst"
  fi
}

BRANCH_NAME="$(current_branch_name)"
BRANCH_SLUG="$(sanitize_branch_name "$BRANCH_NAME")"
TODAY="$(date +%Y%m%d)"
BRANCH_TMP_DIR="${TMP_ROOT_DIR}/${BRANCH_SLUG}"
BRANCH_STATE_DIR="${BRANCH_STATE_ROOT_DIR}/${BRANCH_SLUG}"
TODAY_BRANCH_NOTE="${BRANCH_STATE_DIR}/${TODAY}.md"

mkdir -p "$BRANCH_TMP_DIR" "$BRANCH_STATE_DIR"

install_if_missing "${REF_DIR}/state-template.md" "${STATE_DIR}/STATE.md"
install_if_missing "${REF_DIR}/branch-state-template.md" "${TODAY_BRANCH_NOTE}"
install_if_missing "${REF_DIR}/programming-known-template.md" "${STATE_DIR}/PROGRAMMING_KNOWN.md"
install_if_missing "${REF_DIR}/ci-template.md" "${STATE_DIR}/CI.md"

printf 'Initialized hermes state in %s\n' "$STATE_DIR"
printf 'Branch slug: %s\n' "$BRANCH_SLUG"
printf 'Branch temp dir: %s\n' "$BRANCH_TMP_DIR"
printf 'Branch state note: %s\n' "$TODAY_BRANCH_NOTE"
