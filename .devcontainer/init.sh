#!/bin/bash
set -e

# Activate mise in shell profiles
echo 'eval "$(mise activate bash)"' >>~/.bashrc
echo 'eval "$(mise activate zsh)"' >>~/.zshrc

# Trust and install tools from .tool-versions
mise trust
mise install

# Activate for this shell and generate shims for non-interactive use
eval "$(mise activate bash)"
MISE_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/mise" mise reshim

# Verify chezmoi-recipes is available (mounted from host via devcontainer.json)
if ! command -v chezmoi-recipes &>/dev/null; then
  echo "ERROR: chezmoi-recipes binary not found. Check the mount in devcontainer.json." >&2
  exit 1
fi

# Create XDG directories for testing
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

echo "Development environment ready"
echo "  - Tools installed via mise (bats, chezmoi)"
echo "  - chezmoi-recipes mounted from host ($(chezmoi-recipes version))"
echo "  - Use 'make test' to run e2e tests (bats)"
echo "  - Use 'make check' to lint shell scripts"
