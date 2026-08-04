#!/usr/bin/env bash
# ローカルの mail-receiver に安全な read-only 操作だけを公開する。
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPOSITORY_ROOT="$(cd -- "${SCRIPT_DIR}/../../../.." && pwd -P)"
RECEIVER_ROOT="${REPOSITORY_ROOT}/private/mail-receiver"
CONFIG_PATH="${RECEIVER_ROOT}/accounts.yaml"
BINARY_PATH="${RECEIVER_ROOT}/target/release/mail-receiver"

usage() {
  printf '%s\n' \
    'Usage:' \
    '  mail-search.sh list [--account ALIAS]...' \
    '  mail-search.sh search --query QUERY [--account ALIAS]... [--mailbox NAME]... [--limit COUNT]'
}

if [[ ! -d "$RECEIVER_ROOT" ]] || [[ -L "$RECEIVER_ROOT" ]]; then
  printf 'mail-receiver が通常 directory ではありません。\n' >&2
  exit 2
fi
if [[ ! -f "$CONFIG_PATH" ]] || [[ -L "$CONFIG_PATH" ]]; then
  printf 'mail-receiver の設定 file が見つかりません。\n' >&2
  exit 2
fi

mode="${1:-}"
if [[ "$mode" != 'list' && "$mode" != 'search' ]]; then
  usage >&2
  exit 2
fi
shift

query=''
limit=10
account_args=()
mailbox_args=()
while (($# > 0)); do
  case "$1" in
    --account)
      (($# >= 2)) || { usage >&2; exit 2; }
      account_args+=(--account "$2")
      shift 2
      ;;
    --mailbox)
      (($# >= 2)) || { usage >&2; exit 2; }
      mailbox_args+=(--mailbox "$2")
      shift 2
      ;;
    --query)
      (($# >= 2)) || { usage >&2; exit 2; }
      query="$2"
      shift 2
      ;;
    --limit)
      (($# >= 2)) || { usage >&2; exit 2; }
      limit="$2"
      shift 2
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

cargo build --release --manifest-path "${RECEIVER_ROOT}/Cargo.toml" >&2

if [[ "$mode" == 'list' ]]; then
  if [[ -n "$query" ]] || ((${#mailbox_args[@]} > 0)); then
    usage >&2
    exit 2
  fi
  list_command=("$BINARY_PATH" "$CONFIG_PATH")
  if ((${#account_args[@]} > 0)); then
    list_command+=("${account_args[@]}")
  fi
  list_command+=(--list-mailboxes)
  exec "${list_command[@]}"
fi

if [[ -z "$query" ]] || [[ ! "$limit" =~ ^[0-9]+$ ]] || ((limit < 1 || limit > 100)); then
  usage >&2
  exit 2
fi

TEMP_ROOT="${RECEIVER_ROOT}/tmp"
if [[ -e "$TEMP_ROOT" ]]; then
  if [[ ! -d "$TEMP_ROOT" ]] || [[ -L "$TEMP_ROOT" ]]; then
    printf '検索結果の一時 root が通常 directory ではありません。\n' >&2
    exit 2
  fi
else
  mkdir -m 700 "$TEMP_ROOT"
fi
OUTPUT_DIR="$(mktemp -d "${TEMP_ROOT}/mail-search.XXXXXX")"
chmod 700 "$OUTPUT_DIR"

search_command=("$BINARY_PATH" "$CONFIG_PATH")
if ((${#account_args[@]} > 0)); then
  search_command+=("${account_args[@]}")
fi
search_command+=(
  --search-query "$query"
  --search-output "$OUTPUT_DIR"
  --search-limit "$limit"
)
if ((${#mailbox_args[@]} > 0)); then
  search_command+=("${mailbox_args[@]}")
fi

if ! "${search_command[@]}"; then
  printf '検索に失敗しました。部分出力: %s\n' "$OUTPUT_DIR" >&2
  exit 1
fi

printf 'manifest: %s\n' "${OUTPUT_DIR}/manifest.json"
