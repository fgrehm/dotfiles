#!/usr/bin/env bash
# Stop the old Cartage user service before its managed unit is removed.
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"
set -eo pipefail

if ! command -v systemctl &>/dev/null || ! systemctl --user show-environment &>/dev/null; then
  log_skip "No systemd user manager; no Cartage service to stop"
  exit 0
fi

load_state="$(systemctl --user show cartage.service --property=LoadState --value 2>/dev/null || true)"
if [ "$load_state" != "loaded" ]; then
  log_skip "Cartage user service is not installed"
  exit 0
fi

log_info "Stopping and disabling the removed Cartage user service..."
systemctl --user disable --now cartage.service
systemctl --user daemon-reload
log_info "Cartage user service stopped and disabled"
