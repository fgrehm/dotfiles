#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v jq &>/dev/null; then
  log_skip "jq already installed"
  exit 0
fi

if ! command -v mise &>/dev/null; then
  log_skip "mise not found, skipping jq"
  exit 0
fi

set -eo pipefail

log_info "Installing jq through mise..."
mise use -g jq@latest
jq --version >/dev/null
