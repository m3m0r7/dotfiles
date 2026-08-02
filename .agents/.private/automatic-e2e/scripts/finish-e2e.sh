#!/usr/bin/env bash
# registry に記録された、この E2E run 所有の session だけを終了する。
set -euo pipefail

SESSION_REGISTRY="${1:-${E2E_SESSION_REGISTRY:-}}"

if [[ -z "$SESSION_REGISTRY" ]]; then
  printf 'session registry の path が必要です。\n' >&2
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

  if agent-browser --session "$session_name" close; then
    CLOSED_COUNT=$((CLOSED_COUNT + 1))
  else
    printf 'session を終了できませんでした: %s\n' "$session_name" >&2
    FAILED_COUNT=$((FAILED_COUNT + 1))
  fi
done < <(sort -u "$SESSION_REGISTRY")

printf '所有 session を %d 件終了しました。\n' "$CLOSED_COUNT"

if ((FAILED_COUNT > 0)); then
  printf '終了に失敗した session: %d 件\n' "$FAILED_COUNT" >&2
  exit 1
fi
