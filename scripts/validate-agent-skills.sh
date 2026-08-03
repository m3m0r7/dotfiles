#!/usr/bin/env bash
# skill の構造、token budget、同梱 shell script を検証する。
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPOSITORY_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
SOURCE_ROOT="${REPOSITORY_ROOT}/.agents/.private"
TARGET_ROOT="${REPOSITORY_ROOT}/.agents/skills"
MAX_SKILL_LINES=120
MAX_SKILL_CHARS=4000
MAX_DESCRIPTION_CHARS=300

if [[ ! -d "$SOURCE_ROOT" ]] || [[ -L "$SOURCE_ROOT" ]]; then
  printf 'skill source が通常 directory ではありません: %s\n' "$SOURCE_ROOT" >&2
  exit 1
fi

if [[ ! -d "$TARGET_ROOT" ]] || [[ -L "$TARGET_ROOT" ]]; then
  printf 'agent discovery copy が通常 directory ではありません: %s\n' "$TARGET_ROOT" >&2
  exit 1
fi

SKILL_COUNT=0
TOTAL_LINES=0
TOTAL_CHARS=0

while IFS= read -r skill_directory; do
  skill_name="$(basename -- "$skill_directory")"
  skill_file="${skill_directory}/SKILL.md"
  metadata_file="${skill_directory}/agents/openai.yaml"

  if [[ ! -f "$skill_file" ]] || [[ -L "$skill_file" ]]; then
    printf 'SKILL.md が通常 file ではありません: %s\n' "$skill_file" >&2
    exit 1
  fi

  frontmatter_name="$(sed -n '2s/^name: //p' "$skill_file")"
  description="$(sed -n '3s/^description: //p' "$skill_file")"
  closing_marker="$(sed -n '4p' "$skill_file")"

  if [[ "$(sed -n '1p' "$skill_file")" != '---' ]] || [[ "$closing_marker" != '---' ]]; then
    printf 'frontmatter は name と description の 2 field に限定してください: %s\n' "$skill_file" >&2
    exit 1
  fi

  if [[ "$frontmatter_name" != "$skill_name" ]] || [[ ! "$frontmatter_name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    printf 'skill name と directory 名が一致しません: %s\n' "$skill_file" >&2
    exit 1
  fi

  if [[ -z "$description" ]] || (( ${#description} > MAX_DESCRIPTION_CHARS )); then
    printf 'description が空、または %d 文字を超えています: %s\n' "$MAX_DESCRIPTION_CHARS" "$skill_file" >&2
    exit 1
  fi

  if [[ ! -f "$metadata_file" ]] || [[ -L "$metadata_file" ]]; then
    printf 'agents/openai.yaml が通常 file ではありません: %s\n' "$metadata_file" >&2
    exit 1
  fi

  short_description="$(sed -n 's/^  short_description: "\(.*\)"$/\1/p' "$metadata_file")"
  default_prompt="$(sed -n 's/^  default_prompt: "\(.*\)"$/\1/p' "$metadata_file")"

  if ((${#short_description} < 25 || ${#short_description} > 64)); then
    printf 'short_description は 25〜64 文字にしてください: %s\n' "$metadata_file" >&2
    exit 1
  fi

  if [[ "$default_prompt" != *"\$${skill_name}"* ]]; then
    printf 'default_prompt が $%s を参照していません: %s\n' "$skill_name" "$metadata_file" >&2
    exit 1
  fi

  if [[ ! -d "${TARGET_ROOT}/${skill_name}" ]] || [[ -L "${TARGET_ROOT}/${skill_name}" ]]; then
    printf 'agent discovery copy がありません: %s\n' "$skill_name" >&2
    exit 1
  fi

  if ! diff -qr "$skill_directory" "${TARGET_ROOT}/${skill_name}" >/dev/null; then
    printf '共有正本と agent discovery copy が一致しません: %s\n' "$skill_name" >&2
    exit 1
  fi

  line_count="$(wc -l <"$skill_file" | tr -d ' ')"
  if ((line_count > MAX_SKILL_LINES)); then
    printf 'SKILL.md が %d 行を超えています (%d): %s\n' "$MAX_SKILL_LINES" "$line_count" "$skill_file" >&2
    exit 1
  fi

  char_count="$(wc -m <"$skill_file" | tr -d ' ')"
  if ((char_count > MAX_SKILL_CHARS)); then
    printf 'SKILL.md が %d 文字を超えています (%d): %s\n' "$MAX_SKILL_CHARS" "$char_count" "$skill_file" >&2
    exit 1
  fi

  SKILL_COUNT=$((SKILL_COUNT + 1))
  TOTAL_LINES=$((TOTAL_LINES + line_count))
  TOTAL_CHARS=$((TOTAL_CHARS + char_count))
done < <(find "$SOURCE_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort)

if ((SKILL_COUNT == 0)); then
  printf '検証対象の skill がありません: %s\n' "$SOURCE_ROOT" >&2
  exit 1
fi

while IFS= read -r target_directory; do
  target_name="$(basename -- "$target_directory")"
  if [[ ! -d "${SOURCE_ROOT}/${target_name}" ]]; then
    printf 'agent discovery copy に stale skill があります: %s\n' "$target_name" >&2
    exit 1
  fi
done < <(find "$TARGET_ROOT" -mindepth 1 -maxdepth 1 -type d -print | sort)

while IFS= read -r shell_script; do
  bash -n "$shell_script"
done < <(find "$SOURCE_ROOT" -type f -name '*.sh' -print | sort)

printf 'skills=%d total_skill_lines=%d total_skill_chars=%d max_skill_lines=%d max_skill_chars=%d\n' \
  "$SKILL_COUNT" "$TOTAL_LINES" "$TOTAL_CHARS" "$MAX_SKILL_LINES" "$MAX_SKILL_CHARS"
