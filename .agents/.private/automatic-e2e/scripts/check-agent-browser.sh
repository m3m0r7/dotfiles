#!/usr/bin/env bash
# agent-browser と E2E skill の互換性を browser 操作前に検証する。
set -euo pipefail

if ! command -v agent-browser >/dev/null 2>&1; then
  printf 'agent-browser が見つかりません。setup.sh を実行してください。\n' >&2
  exit 1
fi

VERSION_OUTPUT="$(agent-browser --version 2>/dev/null)" || {
  printf 'agent-browser の version を取得できません。\n' >&2
  exit 1
}

if [[ -z "$VERSION_OUTPUT" ]]; then
  printf 'agent-browser の version 出力が空です。\n' >&2
  exit 1
fi

if ! agent-browser skills get core >/dev/null; then
  printf 'agent-browser から core skill を取得できません。CLI を更新してください。\n' >&2
  exit 1
fi

agent-browser doctor --offline
printf '%s の core workflow と offline doctor を確認しました。\n' "$VERSION_OUTPUT"
