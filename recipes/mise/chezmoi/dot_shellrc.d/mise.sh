# shellcheck shell=bash
# mise (dev tool manager) activation.

if command -v mise >/dev/null 2>&1; then
  if [ -n "$ZSH_VERSION" ]; then
    eval "$(mise activate zsh)"
  elif [ -n "$BASH_VERSION" ]; then
    eval "$(mise activate bash)"
  fi
fi
