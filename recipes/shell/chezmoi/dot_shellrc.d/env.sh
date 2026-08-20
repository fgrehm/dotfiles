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

# --- SSH signing key ---
# Load the commit-signing key into the SSH agent once per login session so Git
# does not prompt for its passphrase on every commit.
if [[ $- == *i* ]] && command -v ssh-add >/dev/null 2>&1; then
  SIGNING_KEY="$HOME/.ssh/id_ed25519-sign"
  if [ -f "$SIGNING_KEY" ] && [ -S "${SSH_AUTH_SOCK:-}" ]; then
    SIGNING_FINGERPRINT=$(ssh-keygen -lf "$SIGNING_KEY" 2>/dev/null | awk '{print $2}')
    if [ -n "$SIGNING_FINGERPRINT" ] && ! ssh-add -l 2>/dev/null | grep -Fq "$SIGNING_FINGERPRINT"; then
      ssh-add "$SIGNING_KEY"
    fi
  fi
fi

# --- Telemetry opt-out ---
export DO_NOT_TRACK=true

# --- History ---
export HISTSIZE=32768
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL=ignoreboth
