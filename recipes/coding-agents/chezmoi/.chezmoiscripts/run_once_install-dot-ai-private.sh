#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

INSTALL_DIR="$HOME/.local/share/dot-ai-private"

if [ ! -d "$INSTALL_DIR" ]; then
  log_info "Cloning dot-ai-private..."
  if ! git clone --quiet git@github.com:fgrehm/dot-ai-private.git "$INSTALL_DIR" 2>/dev/null; then
    log_skip "dot-ai-private not accessible (no SSH keys?), skipping"
    exit 0
  fi
fi

log_info "Configuring dot-ai-private..."
if ! "$INSTALL_DIR/install.sh"; then
  log_error "dot-ai-private install.sh failed"
fi
