#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

INSTALL_DIR="$HOME/.local/share/dot-ai"

_install() {
  set -eo pipefail
  if [ ! -d "$INSTALL_DIR" ]; then
    log_info "Cloning dot-ai..."
    git clone --quiet https://github.com/fgrehm/dot-ai "$INSTALL_DIR"
  fi
  log_info "Configuring dot-ai..."
  "$INSTALL_DIR/install.sh"
}

if ! _install; then
  log_error "Failed to install dot-ai"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
