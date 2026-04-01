#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v mise &>/dev/null; then
  log_skip "mise already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing mise..."
mkdir -p "$HOME/.local/bin"
wget -qO- https://mise.run | sh
