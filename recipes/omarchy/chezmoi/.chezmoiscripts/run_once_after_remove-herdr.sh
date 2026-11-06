#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

if ! command -v herdr &>/dev/null; then
  log_skip "herdr not installed, skipping removal"
  exit 0
fi

log_info "Stopping herdr server..."
herdr server stop 2>/dev/null || true

log_info "Removing herdr package..."
omarchy pkg drop herdr

log_info "herdr removed"
