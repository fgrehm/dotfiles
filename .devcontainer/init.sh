#!/bin/bash
set -e

# Activate mise in shell profiles for interactive use
echo 'eval "$(mise activate bash)"' >>~/.bashrc
echo 'eval "$(mise activate zsh)"' >>~/.zshrc

# Create XDG directories
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

echo "Development environment ready"
echo "  - chezmoi $(chezmoi --version)"
echo "  - chezmoi-recipes $(chezmoi-recipes version)"
echo "  - bats $(bats --version)"
echo "  - Run 'make init' to bootstrap chezmoi (first time only)"
echo "  - Run 'make test' to run e2e tests"
echo "  - Run 'make check' to lint shell scripts"
