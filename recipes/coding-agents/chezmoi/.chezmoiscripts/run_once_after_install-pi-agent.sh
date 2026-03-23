#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v pi &>/dev/null; then
  log_skip "Pi coding agent already installed"
  exit 0
fi

NPM_CMD=()
if command -v mise &>/dev/null && mise which npm &>/dev/null; then
  NPM_CMD=(mise exec node -- npm)
elif command -v npm &>/dev/null; then
  NPM_CMD=(npm)
else
  log_skip "npm not found, skipping Pi coding agent"
  exit 0
fi

_install() {
  set -eo pipefail
  log_info "Installing Pi coding agent..."
  "${NPM_CMD[@]}" install -g @mariozechner/pi-coding-agent
}

if ! _install; then
  log_error "Failed to install Pi coding agent"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
