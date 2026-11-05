#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

plugin="crmne.omastats"
url="https://github.com/crmne/omastats.git"

if ! command -v omarchy &>/dev/null || ! command -v jq &>/dev/null; then
  log_error "omarchy and jq are required to install $plugin"
  exit 1
fi

set -eo pipefail

plugins=$(omarchy plugin list --json)
if jq -e --arg id "$plugin" 'any(.[]; .id == $id and .enabled)' <<<"$plugins" >/dev/null; then
  log_skip "$plugin is already installed and enabled"
  exit 0
fi

if jq -e --arg id "$plugin" 'any(.[]; .id == $id)' <<<"$plugins" >/dev/null; then
  log_info "Enabling installed plugin $plugin..."
  omarchy plugin enable "$plugin" --section right
else
  log_info "Installing $plugin..."
  omarchy plugin add "$url" --enable --yes
  log_info "Placing $plugin in the right bar section..."
  omarchy plugin enable "$plugin" --section right
fi
