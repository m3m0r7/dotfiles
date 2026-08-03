#!/usr/bin/env bash
# automatic-e2e の path、session ownership、失敗時停止を isolated temp directory で検証する。
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
TEMP_BASE="$(cd -- "${TMPDIR:-/tmp}" && pwd -P)"
TEST_ROOT="$(mktemp -d "${TEMP_BASE}/automatic-e2e-test.XXXXXX")"

cleanup() {
  if [[ -z "${TEST_ROOT:-}" ]] || [[ ! -d "$TEST_ROOT" ]] || [[ -L "$TEST_ROOT" ]]; then
    printf 'test root を安全に削除できません: %s\n' "${TEST_ROOT:-unset}" >&2
    return 1
  fi

  case "$TEST_ROOT" in
    "${TEMP_BASE}"/automatic-e2e-test.*)
      rm -rf -- "$TEST_ROOT"
      ;;
    *)
      printf 'test root が許可範囲外です: %s\n' "$TEST_ROOT" >&2
      return 1
      ;;
  esac
}
trap cleanup EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

FAKE_BIN="${TEST_ROOT}/bin"
FAKE_BROWSER_LOG="${TEST_ROOT}/agent-browser.log"
PROJECT_ROOT="${TEST_ROOT}/project"
mkdir -p "$FAKE_BIN" "$PROJECT_ROOT"
git -C "$PROJECT_ROOT" init -q

FAKE_BROWSER="${FAKE_BIN}/agent-browser"
cp "${SCRIPT_DIR}/fixtures/mock-agent-browser.sh" "$FAKE_BROWSER"
chmod 755 "$FAKE_BROWSER"

export FAKE_BROWSER_LOG
export PATH="${FAKE_BIN}:${PATH}"

if bash "${SCRIPT_DIR}/init-e2e.sh" >/dev/null 2>&1; then
  fail 'project root がない初期化を受理した'
fi

INIT_OUTPUT="$(E2E_RUN_ID='test-run' bash "${SCRIPT_DIR}/init-e2e.sh" "$PROJECT_ROOT")"
eval "$(printf '%s\n' "$INIT_OUTPUT" | sed -n '/^export /p')"

case "$EVIDENCE_DIR" in
  "${PROJECT_ROOT}"/tmp/e2e/*/e2e-evidence/test-run) ;;
  *) fail "evidence directory が project 配下ではない: $EVIDENCE_DIR" ;;
esac

[[ -f "$HOW_TO_FILE" ]] || fail 'plan template が作成されていない'
[[ -f "$E2E_SESSION_REGISTRY" ]] || fail 'session registry が作成されていない'

OWNED_SESSION="${E2E_SESSION_PREFIX}-normal"
bash "${SCRIPT_DIR}/ab.sh" --session "$OWNED_SESSION" open 'http://127.0.0.1:3000'
grep -Fx "$OWNED_SESSION" "$E2E_SESSION_REGISTRY" >/dev/null || fail 'owned session が registry に記録されていない'
grep -F -- "--headed false --session ${OWNED_SESSION}" "$FAKE_BROWSER_LOG" >/dev/null || fail 'headless 実行を強制していない'

if bash "${SCRIPT_DIR}/ab.sh" --session "$OWNED_SESSION" --headed true open 'http://127.0.0.1:3000' >/dev/null 2>&1; then
  fail 'headed override を受理した'
fi

if bash "${SCRIPT_DIR}/ab.sh" --session 'foreign-session' open 'http://127.0.0.1:3000' >/dev/null 2>&1; then
  fail 'prefix 外の session を受理した'
fi

FOREIGN_REGISTRY="${EVIDENCE_DIR}/foreign-sessions.txt"
printf '%s\n' 'foreign-session' >"$FOREIGN_REGISTRY"
if bash "${SCRIPT_DIR}/finish-e2e.sh" "$FOREIGN_REGISTRY" "$E2E_SESSION_PREFIX" >/dev/null 2>&1; then
  fail 'prefix 外の session を終了対象にした'
fi

if grep -F -- '--session foreign-session close' "$FAKE_BROWSER_LOG" >/dev/null; then
  fail 'prefix 外の session へ close を実行した'
fi

bash "${SCRIPT_DIR}/finish-e2e.sh" "$E2E_SESSION_REGISTRY" "$E2E_SESSION_PREFIX"
grep -F -- "--session ${OWNED_SESSION} close" "$FAKE_BROWSER_LOG" >/dev/null || fail 'owned session を終了していない'

SYMLINK_PROJECT="${TEST_ROOT}/symlink-project"
SYMLINK_TARGET="${TEST_ROOT}/outside-state"
mkdir -p "$SYMLINK_PROJECT" "$SYMLINK_TARGET"
git -C "$SYMLINK_PROJECT" init -q
ln -s "$SYMLINK_TARGET" "${SYMLINK_PROJECT}/tmp"

if E2E_RUN_ID='symlink-test' bash "${SCRIPT_DIR}/init-e2e.sh" "$SYMLINK_PROJECT" >/dev/null 2>&1; then
  fail 'symbolic link の state path を受理した'
fi

[[ -z "$(find "$SYMLINK_TARGET" -mindepth 1 -print -quit)" ]] || fail 'symbolic link の外側へ書き込んだ'

printf 'automatic-e2e script tests: OK\n'
