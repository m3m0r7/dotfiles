#!/usr/bin/env bash
# Initialize the E2E workspace for the current branch under hermes state.
# - Resolves the branch slug (same sanitization rule as hermes).
# - Ensures the branch e2e dir exists and seeds HOW_TO_E2E_TEST.md.
# - RESETS the evidence dir every run, so re-running E2E always starts from
#   scratch and never mixes screenshots from a previous run.
set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="${SCRIPT_DIR}/../references"
STATE_DIR="${PROJECT_ROOT}/.hermes-prj-states"
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

BRANCH_NAME="$(current_branch_name)"
BRANCH_SLUG="$(sanitize_branch_name "$BRANCH_NAME")"
BRANCH_STATE_DIR="${BRANCH_STATE_ROOT_DIR}/${BRANCH_SLUG}"
HOW_TO_FILE="${BRANCH_STATE_DIR}/HOW_TO_E2E_TEST.md"
EVIDENCE_DIR="${BRANCH_STATE_DIR}/e2e-evidence"

mkdir -p "$BRANCH_STATE_DIR"

# Seed the plan/auth note once; never overwrite an existing one.
if [ ! -e "$HOW_TO_FILE" ] && [ -e "${REF_DIR}/how-to-e2e-test-template.md" ]; then
  cp "${REF_DIR}/how-to-e2e-test-template.md" "$HOW_TO_FILE"
fi

# Always reset evidence so a re-run starts from a clean slate.
rm -rf "$EVIDENCE_DIR"
mkdir -p "$EVIDENCE_DIR"

printf 'Initialized E2E workspace for branch slug: %s\n' "$BRANCH_SLUG"
printf 'Plan/auth note: %s\n' "$HOW_TO_FILE"
printf 'Evidence dir (reset): %s\n' "$EVIDENCE_DIR"

# Machine-readable lines for the caller to eval:
#   eval "$(scripts/init-e2e.sh | grep -E '^(EVIDENCE_DIR|HOW_TO_FILE)=')"
printf 'EVIDENCE_DIR=%s\n' "$EVIDENCE_DIR"
printf 'HOW_TO_FILE=%s\n' "$HOW_TO_FILE"
