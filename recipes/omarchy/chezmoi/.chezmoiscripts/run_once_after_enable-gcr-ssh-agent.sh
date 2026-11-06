#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if ! command -v omarchy >/dev/null 2>&1; then
  log_error "omarchy command not found; cannot enable the GCR SSH agent"
  exit 1
fi

set -eo pipefail

log_info "Enabling Omarchy's GCR SSH agent for host and container use..."
omarchy setup security ssh agent
