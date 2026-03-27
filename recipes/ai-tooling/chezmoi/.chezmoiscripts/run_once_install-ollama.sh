#!/bin/env bash
# vim: ft=bash
# Skipped in containers via .chezmoiignore
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v ollama &>/dev/null; then
  log_skip "ollama already installed"
  exit 0
fi

_install() {
  set -eo pipefail
  log_info "Installing ollama..."
  wget -qO- https://ollama.com/install.sh | sh
}

if ! _install; then
  log_error "Failed to install ollama (network unavailable?)"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
