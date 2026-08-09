#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# theme.lua is a symlink to the current Omarchy theme's neovim.lua, so it
# follows `omarchy theme set`. It can't live in the repo as a static file
# (that would pin the colorscheme) or as a relative symlink (the repo's
# config/nvim is symlinked into ~/.config/nvim, so relative targets resolve
# against the repo path). Create the absolute symlink here instead.
THEME_LINK="$HOME/.config/nvim/lua/plugins/theme.lua"
THEME_TARGET="$HOME/.config/omarchy/current/theme/neovim.lua"

if [ -L "$THEME_LINK" ]; then
  log_skip "theme.lua symlink already exists"
  exit 0
fi

set -eo pipefail

if [ ! -e "$THEME_TARGET" ]; then
  log_error "Omarchy theme neovim.lua not found at $THEME_TARGET"
  exit 1
fi

log_info "Linking theme.lua to Omarchy theme..."
ln -s "$THEME_TARGET" "$THEME_LINK"
