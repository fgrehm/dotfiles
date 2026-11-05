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

# --- Build parallelism ---
# Keep language toolchains from using every CPU by default. Respect an
# explicitly configured value, so these remain easy to override per project.
if command -v getconf >/dev/null 2>&1; then
  BUILD_JOBS=$((($(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1) + 1) / 2))
else
  BUILD_JOBS=1
fi
[ "$BUILD_JOBS" -lt 1 ] && BUILD_JOBS=1

: "${CARGO_BUILD_JOBS:=$BUILD_JOBS}"
export CARGO_BUILD_JOBS
: "${BUNDLE_JOBS:=$BUILD_JOBS}"
export BUNDLE_JOBS
: "${MAKEFLAGS:=-j$BUILD_JOBS}"
export MAKEFLAGS
: "${GOFLAGS:=-p=$BUILD_JOBS}"
export GOFLAGS

# --- Telemetry opt-out ---
export DO_NOT_TRACK=true

# --- History ---
export HISTSIZE=32768
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL=ignoreboth
