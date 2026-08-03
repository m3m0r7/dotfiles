#!/usr/bin/env bash
# registry と prefix の両方に一致する、この run 所有の session だけを終了する。
set -euo pipefail

SESSION_REGISTRY="${1:-${E2E_SESSION_REGISTRY:-}}"
SESSION_PREFIX="${2:-${E2E_SESSION_PREFIX:-}}"

if [[ -z "$SESSION_REGISTRY" ]] || [[ -z "$SESSION_PREFIX" ]]; then
  printf 'session registry と session prefix が必要です。\n' >&2
  exit 1
fi

if [[ ! "$SESSION_PREFIX" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  printf '不正な session prefix です: %s\n' "$SESSION_PREFIX" >&2
  exit 1
fi

if [[ -L "$SESSION_REGISTRY" ]] || [[ ! -f "$SESSION_REGISTRY" ]]; then
  printf 'session registry が通常 file ではありません: %s\n' "$SESSION_REGISTRY" >&2
  exit 1
fi

CLOSED_COUNT=0
FAILED_COUNT=0

while IFS= read -r session_name; do
  [[ -z "$session_name" ]] && continue

  if [[ ! "$session_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    printf '不正な session 名を拒否しました: %s\n' "$session_name" >&2
    FAILED_COUNT=$((FAILED_COUNT + 1))
    continue
  fi

  if [[ "$session_name" != "$SESSION_PREFIX" ]] && [[ "$session_name" != "${SESSION_PREFIX}-"* ]]; then
    printf '所有 prefix 外の session を拒否しました: %s\n' "$session_name" >&2
    FAILED_COUNT=$((FAILED_COUNT + 1))
    continue
  fi

  if agent-browser --session "$session_name" close; then
    CLOSED_COUNT=$((CLOSED_COUNT + 1))
  else
    printf 'session を終了できませんでした: %s\n' "$session_name" >&2
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
done < <(sort -u "$SESSION_REGISTRY")

printf '所有 session を %d 件終了しました。\n' "$CLOSED_COUNT"

if ((FAILED_COUNT > 0)); then
  printf '拒否または終了失敗した session: %d 件\n' "$FAILED_COUNT" >&2
  exit 1
fi
