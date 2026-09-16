#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

OLD_COMMAND="$HOME/.local/bin/pi-usage-snapshot"
if [ -e "$OLD_COMMAND" ] || [ -L "$OLD_COMMAND" ]; then
  rm -f "$OLD_COMMAND"
  log_info "Removed stale pi-usage-snapshot command"
else
  log_skip "No stale pi-usage-snapshot command found"
fi
