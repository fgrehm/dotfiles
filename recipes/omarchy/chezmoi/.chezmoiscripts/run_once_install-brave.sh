#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v brave &>/dev/null; then
  log_skip "brave already installed"
  # still ensure it's the default browser for Omarchy and XDG handlers
  omarchy default browser brave
  exit 0
fi

set -eo pipefail

log_info "Installing brave and setting as default browser..."
omarchy install browser brave
omarchy default browser brave
