#!/bin/env bash
set -eo pipefail

source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if [ -d "$HOME/.oh-my-zsh" ]; then
  log_skip "Oh My Zsh already installed"
  exit 0
fi

log_info "Installing Oh My Zsh..."
export KEEP_ZSHRC=yes
sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
