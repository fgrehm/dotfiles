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
LAZY_LOG="${TMPDIR:-/tmp}/nvim-lazy-sync.log"
if ! timeout 120 nvim --headless "+Lazy! sync" +qa >"$LAZY_LOG" 2>&1; then
  log_error "Neovim plugin sync failed. Output:"
  cat "$LAZY_LOG"
  exit 1
fi
