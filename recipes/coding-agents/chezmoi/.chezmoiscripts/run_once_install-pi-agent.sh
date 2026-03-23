#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v pi &>/dev/null; then
  log_skip "Pi coding agent already installed"
  exit 0
fi

if ! command -v npm &>/dev/null; then
  log_skip "npm not found, skipping Pi coding agent"
  exit 0
fi

_install() {
  set -e
  log_info "Installing Pi coding agent..."
  npm install -g @mariozechner/pi-coding-agent
}

if ! _install; then
  log_error "Failed to install Pi coding agent"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
