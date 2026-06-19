#!/usr/bin/env bash
# Headless-enforced wrapper around agent-browser.
# Always runs headless so a browser GUI never pops up and disturbs the user,
# regardless of AGENT_BROWSER_HEADED or a "headed": true config entry.
#
# Usage: ab.sh <agent-browser args...>
#   scripts/ab.sh --session e2e-normal open https://app.example.com
#   scripts/ab.sh --session e2e-normal screenshot --screenshot-dir <evidence-dir>
set -euo pipefail

# Drop any inherited env that would force headed mode.
unset AGENT_BROWSER_HEADED

# `--headed false` overrides config.json / project config (CLI flags win).
exec agent-browser --headed false "$@"
