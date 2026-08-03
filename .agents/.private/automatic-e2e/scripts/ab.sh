#!/usr/bin/env bash
# この E2E run が所有する session だけを headless で操作する。
set -euo pipefail

if [[ -z "${E2E_SESSION_PREFIX:-}" ]] || [[ -z "${E2E_SESSION_REGISTRY:-}" ]] || [[ -z "${EVIDENCE_DIR:-}" ]]; then
  printf '先に init-e2e.sh を実行し、出力された変数を export してください。\n' >&2
  exit 1
fi

SESSION_NAME=''
ARGS=("$@")

for ((argument_index = 0; argument_index < ${#ARGS[@]}; argument_index++)); do
  case "${ARGS[$argument_index]}" in
    --session)
      if ((argument_index + 1 >= ${#ARGS[@]})); then
        printf '%s\n' '--session の値がありません。' >&2
        exit 1
      fi
      SESSION_NAME="${ARGS[$((argument_index + 1))]}"
      ;;
    --session=*)
      SESSION_NAME="${ARGS[$argument_index]#--session=}"
      ;;
    --headed | --headed=*)
      printf '%s\n' '--headed は wrapper が管理します。' >&2
      exit 1
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

if [[ -L "$EVIDENCE_DIR" ]] || [[ ! -d "$EVIDENCE_DIR" ]]; then
  printf 'evidence directory が通常 directory ではありません: %s\n' "$EVIDENCE_DIR" >&2
  exit 1
fi

if [[ -L "$E2E_SESSION_REGISTRY" ]] || [[ ! -f "$E2E_SESSION_REGISTRY" ]]; then
  printf 'session registry が通常 file ではありません: %s\n' "$E2E_SESSION_REGISTRY" >&2
  exit 1
fi

if [[ "$(cd -- "$(dirname -- "$E2E_SESSION_REGISTRY")" && pwd -P)" != "$(cd -- "$EVIDENCE_DIR" && pwd -P)" ]]; then
  printf 'session registry が evidence directory の外にあります: %s\n' "$E2E_SESSION_REGISTRY" >&2
  exit 1
fi

printf '%s\n' "$SESSION_NAME" >>"$E2E_SESSION_REGISTRY"

unset AGENT_BROWSER_HEADED
exec agent-browser --headed false "$@"
