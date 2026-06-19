#!/usr/bin/env bash
# Tear down all agent-browser sessions after E2E testing.
# Run this at the end of every E2E session so no browser process is left behind.
set -euo pipefail

agent-browser close --all || true

printf 'Closed all agent-browser sessions.\n'
printf 'Verify no stray processes remain:\n'
pgrep -al agent-browser 2>/dev/null || printf '  (none)\n'
