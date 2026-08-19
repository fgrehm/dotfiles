#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if [[ -x /usr/lib/seahorse/ssh-askpass ]]; then
  log_skip "ssh-askpass already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing Seahorse SSH askpass..."
omarchy pkg add seahorse
