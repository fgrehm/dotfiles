#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if ! command -v mise &>/dev/null; then
  log_skip "mise not found, skipping formatting tools"
  exit 0
fi

set -eo pipefail

if command -v shfmt &>/dev/null; then
  log_skip "shfmt already installed"
else
  log_info "Installing shfmt through mise..."
  mise use -g shfmt@latest
fi

if command -v bunx &>/dev/null; then
  log_skip "bunx already installed"
else
  log_info "Installing bun through mise..."
  mise use -g bun@latest
fi

if command -v shellcheck &>/dev/null; then
  log_skip "shellcheck already installed"
else
  log_info "Installing shellcheck through mise..."
  mise use -g shellcheck@latest
fi

shfmt --version >/dev/null
bunx --version >/dev/null
shellcheck --version >/dev/null
