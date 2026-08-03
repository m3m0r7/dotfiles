#!/usr/bin/env bash
# 共有する skill の正本を、各 agent が読む生成先へ同期する。
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPOSITORY_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
SOURCE_ROOT="${REPOSITORY_ROOT}/.agents/.private"
TARGET_ROOT="${REPOSITORY_ROOT}/.agents/skills"

if [[ ! -d "$SOURCE_ROOT" ]] || [[ -L "$SOURCE_ROOT" ]]; then
  printf 'skill source が通常 directory ではありません: %s\n' "$SOURCE_ROOT" >&2
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  printf 'rsync が見つかりません。\n' >&2
  exit 1
fi

if [[ -L "$TARGET_ROOT" ]]; then
  printf 'skill target に symbolic link は使えません: %s\n' "$TARGET_ROOT" >&2
  exit 1
fi

mkdir -p "$TARGET_ROOT"

if [[ "$(cd -- "$TARGET_ROOT" && pwd -P)" != "$TARGET_ROOT" ]]; then
  printf 'skill target の実体が想定 path と一致しません: %s\n' "$TARGET_ROOT" >&2
  exit 1
fi

if find "$SOURCE_ROOT" "$TARGET_ROOT" -type l -print -quit | grep -q .; then
  printf 'skill source/target 配下に symbolic link は使えません。\n' >&2
  exit 1
fi

SYNCED_COUNT=0
while IFS= read -r source_directory; do
  skill_name="$(basename -- "$source_directory")"

  if [[ ! "$skill_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    printf '不正な skill directory 名です: %s\n' "$skill_name" >&2
    exit 1
  fi

  SYNCED_COUNT=$((SYNCED_COUNT + 1))
done < <(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort)

if ((SYNCED_COUNT == 0)); then
  printf '同期対象の skill がありません: %s\n' "$SOURCE_ROOT" >&2
  exit 1
fi

# TARGET_ROOT は生成物専用。正本から消えた skill も残さない。
rsync --archive --delete \
  --exclude '.DS_Store' \
  --exclude '.gitkeep' \
  "${SOURCE_ROOT}/" "${TARGET_ROOT}/"

printf 'agent skills を %d 件同期しました。\n' "$SYNCED_COUNT"
