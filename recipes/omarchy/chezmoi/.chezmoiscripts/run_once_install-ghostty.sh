#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v ghostty &>/dev/null; then
  log_skip "ghostty already installed"
  # still ensure it's the default terminal for xdg-terminal-exec
  omarchy default terminal ghostty
  exit 0
fi

set -eo pipefail

log_info "Installing ghostty and setting as default terminal..."
omarchy install terminal ghostty
