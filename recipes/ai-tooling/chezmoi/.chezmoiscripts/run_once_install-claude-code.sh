#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v claude &>/dev/null; then
  log_skip "Claude Code already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing Claude Code..."
wget -qO- https://claude.ai/install.sh | bash
