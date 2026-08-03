#!/usr/bin/env bash
# 対象 project に E2E plan、証跡 directory、session registry を作る。
set -euo pipefail

if (($# != 1)); then
  printf 'usage: %s <project-root>\n' "${0##*/}" >&2
  exit 1
fi

PROJECT_INPUT="$1"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REF_DIR="${SCRIPT_DIR}/../references"

if [[ ! -d "$PROJECT_INPUT" ]]; then
  printf 'project root が directory ではありません: %s\n' "$PROJECT_INPUT" >&2
  exit 1
fi

PROJECT_ROOT="$(cd -- "$PROJECT_INPUT" && pwd -P)"
if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'project root が Git worktree ではありません: %s\n' "$PROJECT_ROOT" >&2
  exit 1
fi

bash "${SCRIPT_DIR}/check-agent-browser.sh"

sanitize_name() {
  local raw_value="$1"

  raw_value="$(printf '%s' "$raw_value" | tr '[:upper:]' '[:lower:]')"
  raw_value="$(printf '%s' "$raw_value" | sed -E 's#[^a-z0-9._-]+#-#g; s#-+#-#g; s#(^[-.]+|[-.]+$)##g')"
  printf '%s' "$raw_value"
}

BRANCH_NAME="$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || true)"
if [[ -z "$BRANCH_NAME" ]]; then
  BRANCH_NAME="detached-$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)"
fi

BRANCH_SLUG="$(sanitize_name "$BRANCH_NAME")"
BRANCH_HASH="$(printf '%s' "$BRANCH_NAME" | cksum | awk '{print $1}')"
BRANCH_KEY="${BRANCH_SLUG:0:48}-${BRANCH_HASH}"
if [[ ! "$BRANCH_KEY" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  printf '安全な branch key を生成できません: %s\n' "$BRANCH_KEY" >&2
  exit 1
fi

RAW_RUN_ID="${E2E_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
RUN_ID="$(sanitize_name "$RAW_RUN_ID")"
RUN_ID="${RUN_ID:0:48}"
if [[ -z "$RUN_ID" ]]; then
  printf 'run ID を生成できません。\n' >&2
  exit 1
fi

TMP_DIR="${PROJECT_ROOT}/tmp"
STATE_DIR="${TMP_DIR}/e2e"
BRANCH_STATE_DIR="${STATE_DIR}/${BRANCH_KEY}"
EVIDENCE_ROOT="${BRANCH_STATE_DIR}/e2e-evidence"
HOW_TO_FILE="${BRANCH_STATE_DIR}/HOW_TO_E2E_TEST.md"

for checked_directory in "$TMP_DIR" "$STATE_DIR" "$BRANCH_STATE_DIR" "$EVIDENCE_ROOT"; do
  if [[ -L "$checked_directory" ]]; then
    printf 'E2E state path に symbolic link は使えません: %s\n' "$checked_directory" >&2
    exit 1
  fi
done

mkdir -p "$EVIDENCE_ROOT"
if [[ "$(cd -- "$EVIDENCE_ROOT" && pwd -P)" != "$EVIDENCE_ROOT" ]]; then
  printf 'E2E evidence root の実体が想定 path と一致しません: %s\n' "$EVIDENCE_ROOT" >&2
  exit 1
fi

EVIDENCE_DIR=''
for ((attempt = 0; attempt < 100; attempt++)); do
  RESOLVED_RUN_ID="$RUN_ID"
  if ((attempt > 0)); then
    RESOLVED_RUN_ID="${RUN_ID}-${attempt}"
  fi

  candidate_directory="${EVIDENCE_ROOT}/${RESOLVED_RUN_ID}"
  if mkdir "$candidate_directory" 2>/dev/null; then
    EVIDENCE_DIR="$candidate_directory"
    RUN_ID="$RESOLVED_RUN_ID"
    break
  fi
done

if [[ -z "$EVIDENCE_DIR" ]]; then
  printf '空いている run directory を確保できません: %s\n' "$EVIDENCE_ROOT" >&2
  exit 1
fi

E2E_SESSION_REGISTRY="${EVIDENCE_DIR}/sessions.txt"
E2E_SESSION_PREFIX="automatic-e2e-${BRANCH_HASH}-${RUN_ID}"
E2E_SESSION_PREFIX="${E2E_SESSION_PREFIX:0:96}"

if [[ ! "$E2E_SESSION_PREFIX" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  printf '安全な session prefix を生成できません: %s\n' "$E2E_SESSION_PREFIX" >&2
  exit 1
fi

: >"$E2E_SESSION_REGISTRY"

if [[ ! -e "$HOW_TO_FILE" ]] && [[ -f "${REF_DIR}/how-to-e2e-test-template.md" ]] && [[ ! -L "${REF_DIR}/how-to-e2e-test-template.md" ]]; then
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
