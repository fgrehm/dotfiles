#!/bin/env bash
# vim: ft=bash
set -eo pipefail

source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# Ensure chezmoi-managed binaries are on PATH
export PATH="$HOME/.local/bin:$PATH"

if ! command -v nvim &>/dev/null; then
  log_skip "Neovim not found, skipping plugin setup"
  exit 0
fi

if [ -d "$HOME/.local/share/nvim/lazy/LazyVim" ]; then
  log_skip "Neovim plugins already installed"
  exit 0
fi

log_info "Installing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa >"${TMPDIR:-/tmp}/nvim-lazy-sync.log" 2>&1
echo
