# shellcheck shell=bash
# Environment variables, editor setup, and PATH configuration.

# --- PATH ---
if [ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- Editor ---
if command -v nvim >/dev/null 2>&1; then
  EDITOR=$(which nvim)
  export EDITOR
  export SUDO_EDITOR="$EDITOR"
  alias vim='nvim'
fi

# --- History ---
export HISTSIZE=32768
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL=ignoreboth
