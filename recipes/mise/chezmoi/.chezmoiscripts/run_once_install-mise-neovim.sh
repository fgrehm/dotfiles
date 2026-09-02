#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v nvim &>/dev/null; then
  log_skip "Neovim already installed"
  exit 0
fi

if ! command -v mise &>/dev/null; then
  log_skip "mise not found, skipping Neovim"
  exit 0
fi

set -eo pipefail

log_info "Installing Neovim through mise..."
mise use -g neovim@latest
nvim --version >/dev/null
