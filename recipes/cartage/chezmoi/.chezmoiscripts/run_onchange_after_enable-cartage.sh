#!/bin/env bash
# vim: ft=bash.gotmpl
# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"
set -eo pipefail
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# {{ if .isContainer }}
log_skip "Container environment, skipping cartage service setup"
exit 0
# {{ end }}

if ! command -v cartage &>/dev/null; then
  log_skip "Cartage not found, skipping service setup"
  exit 0
fi

if ! systemctl --user status &>/dev/null; then
  log_skip "Systemd user session not available"
  exit 0
fi

log_info "Enabling cartage systemd service..."
systemctl --user daemon-reload
systemctl --user enable --now cartage.service
