#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v restic &>/dev/null; then
  log_skip "Restic already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing Restic for encrypted WIP backups..."
omarchy pkg add restic

if ! command -v restic &>/dev/null; then
  log_error "Restic did not become available after installation"
  exit 1
fi
