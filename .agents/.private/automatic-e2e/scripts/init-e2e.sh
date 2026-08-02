#!/usr/bin/env bash
# E2E run の計画、証跡 directory、所有 session registry を初期化する。
set -euo pipefail

PROJECT_ROOT="$(cd -- "${1:-$(pwd)}" && pwd)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REF_DIR="${SCRIPT_DIR}/../references"
STATE_DIR="${PROJECT_ROOT}/tmp/e2e"

bash "${SCRIPT_DIR}/check-agent-browser.sh"

current_branch_name() {
  if git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || true
  fi
}

sanitize_name() {
  local raw="$1"

  raw="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]')"
  raw="$(printf '%s' "$raw" | sed -E 's#[^a-z0-9._-]+#-#g; s#-+#-#g; s#(^[-.]+|[-.]+$)##g')"
  printf '%s' "$raw"
}

BRANCH_NAME="$(current_branch_name)"
if [[ -z "$BRANCH_NAME" ]]; then
  BRANCH_NAME="detached-$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || printf 'head')"
fi

BRANCH_SLUG="$(sanitize_name "$BRANCH_NAME")"
if [[ -z "$BRANCH_SLUG" ]]; then
  printf 'branch slug を生成できません。\n' >&2
  exit 1
fi

RAW_RUN_ID="${E2E_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
RUN_ID="$(sanitize_name "$RAW_RUN_ID")"
RUN_ID="${RUN_ID:0:48}"
if [[ -z "$RUN_ID" ]]; then
  printf 'run ID を生成できません。\n' >&2
  exit 1
fi

BRANCH_STATE_DIR="${STATE_DIR}/${BRANCH_SLUG}"
HOW_TO_FILE="${BRANCH_STATE_DIR}/HOW_TO_E2E_TEST.md"

if [[ -L "$STATE_DIR" ]] || [[ -L "$BRANCH_STATE_DIR" ]]; then
  printf 'E2E state directory に symbolic link は使えません: %s\n' "$BRANCH_STATE_DIR" >&2
  exit 1
fi

EVIDENCE_ROOT="${BRANCH_STATE_DIR}/e2e-evidence"
for ((attempt = 0; attempt < 100; attempt++)); do
  RESOLVED_RUN_ID="$RUN_ID"
  if ((attempt > 0)); then
    RESOLVED_RUN_ID="${RUN_ID}-${attempt}"
  fi

  EVIDENCE_DIR="${EVIDENCE_ROOT}/${RESOLVED_RUN_ID}"
  [[ ! -e "$EVIDENCE_DIR" ]] && break
done

if [[ -e "$EVIDENCE_DIR" ]]; then
  printf '空いている run directory を確保できません: %s\n' "$EVIDENCE_ROOT" >&2
  exit 1
fi

RUN_ID="$RESOLVED_RUN_ID"
E2E_SESSION_REGISTRY="${EVIDENCE_DIR}/sessions.txt"
E2E_SESSION_PREFIX="automatic-e2e-${RUN_ID}"

if [[ ! "$E2E_SESSION_PREFIX" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  printf '安全な session prefix を生成できません: %s\n' "$E2E_SESSION_PREFIX" >&2
  exit 1
fi

mkdir -p "$EVIDENCE_DIR"
: >"$E2E_SESSION_REGISTRY"

if [[ ! -e "$HOW_TO_FILE" ]] && [[ -e "${REF_DIR}/how-to-e2e-test-template.md" ]]; then
  cp "${REF_DIR}/how-to-e2e-test-template.md" "$HOW_TO_FILE"
fi

printf 'E2E run を初期化しました: %s\n' "$RUN_ID"
printf 'Plan: %s\n' "$HOW_TO_FILE"
printf 'Evidence: %s\n' "$EVIDENCE_DIR"
printf 'Session prefix: %s\n' "$E2E_SESSION_PREFIX"

printf 'export HOW_TO_FILE=%q\n' "$HOW_TO_FILE"
printf 'export EVIDENCE_DIR=%q\n' "$EVIDENCE_DIR"
printf 'export E2E_SESSION_PREFIX=%q\n' "$E2E_SESSION_PREFIX"
printf 'export E2E_SESSION_REGISTRY=%q\n' "$E2E_SESSION_REGISTRY"
