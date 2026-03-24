#!/bin/env bash
set -eo pipefail

source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# Check both $HOME/.oh-my-zsh and $ZSH (devcontainers may pre-set $ZSH)
if [ -d "${ZSH:-$HOME/.oh-my-zsh}" ]; then
  log_skip "Oh My Zsh already installed"
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
else
  SUDO=""
fi

_install() {
  set -eo pipefail
  if ! command -v zsh &>/dev/null; then
    log_info "Installing zsh..."
    $SUDO apt-get update -qq
    $SUDO apt-get install -y zsh
  fi
  log_info "Installing Oh My Zsh..."
  # Prevent the installer from replacing our chezmoi-managed .zshrc.
  # Unset ZSH so the installer defaults to $HOME/.oh-my-zsh.
  export KEEP_ZSHRC=yes
  unset ZSH
  sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

if ! _install; then
  log_error "Failed to install Oh My Zsh"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
