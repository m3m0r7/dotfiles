#!/usr/bin/env bash
# agent-browser と E2E skill の互換性をブラウザ操作前に検証する。
set -euo pipefail

MIN_AGENT_BROWSER_VERSION="0.26.0"

version_at_least() {
  local actual="$1"
  local required="$2"
  local actual_major actual_minor actual_patch
  local required_major required_minor required_patch

  IFS=. read -r actual_major actual_minor actual_patch <<<"$actual"
  IFS=. read -r required_major required_minor required_patch <<<"$required"

  if ((actual_major != required_major)); then
    ((actual_major > required_major))
    return
  fi

  if ((actual_minor != required_minor)); then
    ((actual_minor > required_minor))
    return
  fi

  ((actual_patch >= required_patch))
}

if ! command -v agent-browser >/dev/null 2>&1; then
  printf 'agent-browser が見つかりません。setup.sh を実行してください。\n' >&2
  exit 1
fi

VERSION_OUTPUT="$(agent-browser --version 2>/dev/null)" || {
  printf 'agent-browser の version を取得できません。0.26.0 以上へ更新してください。\n' >&2
  exit 1
}

ACTUAL_VERSION="$(printf '%s\n' "$VERSION_OUTPUT" | awk 'match($0, /[0-9]+\.[0-9]+\.[0-9]+/) { print substr($0, RSTART, RLENGTH); exit }')"

if [[ -z "$ACTUAL_VERSION" ]] || ! version_at_least "$ACTUAL_VERSION" "$MIN_AGENT_BROWSER_VERSION"; then
  printf 'agent-browser %s は非対応です。必要 version: %s 以上。\n' "${ACTUAL_VERSION:-unknown}" "$MIN_AGENT_BROWSER_VERSION" >&2
  exit 1
fi

if ! agent-browser skills get core >/dev/null; then
  printf 'agent-browser から core skill を取得できません。CLI の installation を確認してください。\n' >&2
  exit 1
fi

agent-browser doctor --offline
printf 'agent-browser %s の互換性と headless 起動を確認しました。\n' "$ACTUAL_VERSION"
