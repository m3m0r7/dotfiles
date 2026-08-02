#!/usr/bin/env bash
# 所有 session のみを headless で操作する agent-browser wrapper。
set -euo pipefail

if [[ -z "${E2E_SESSION_PREFIX:-}" ]] || [[ -z "${E2E_SESSION_REGISTRY:-}" ]]; then
  printf '先に init-e2e.sh を実行し、出力された変数を export してください。\n' >&2
  exit 1
fi

SESSION_NAME=""
ARGS=("$@")

for ((index = 0; index < ${#ARGS[@]}; index++)); do
  case "${ARGS[$index]}" in
    --session)
      if ((index + 1 >= ${#ARGS[@]})); then
        printf '%s\n' '--session の値がありません。' >&2
        exit 1
      fi
      SESSION_NAME="${ARGS[$((index + 1))]}"
      ;;
    --session=*)
      SESSION_NAME="${ARGS[$index]#--session=}"
      ;;
  esac
done

if [[ -z "$SESSION_NAME" ]]; then
  printf '所有範囲を限定するため --session が必要です。\n' >&2
  exit 1
fi

if [[ "$SESSION_NAME" != "$E2E_SESSION_PREFIX" ]] && [[ "$SESSION_NAME" != "${E2E_SESSION_PREFIX}-"* ]]; then
  printf 'session は所有 prefix %s を使ってください: %s\n' "$E2E_SESSION_PREFIX" "$SESSION_NAME" >&2
  exit 1
fi

if [[ ! "$SESSION_NAME" =~ ^[a-zA-Z0-9._-]+$ ]]; then
  printf '不正な session 名です: %s\n' "$SESSION_NAME" >&2
  exit 1
fi

if [[ -L "$E2E_SESSION_REGISTRY" ]] || [[ ! -f "$E2E_SESSION_REGISTRY" ]]; then
  printf 'session registry が通常 file ではありません: %s\n' "$E2E_SESSION_REGISTRY" >&2
  exit 1
fi

printf '%s\n' "$SESSION_NAME" >>"$E2E_SESSION_REGISTRY"

unset AGENT_BROWSER_HEADED
exec agent-browser --headed false "$@"
