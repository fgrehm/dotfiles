#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v omasnap &>/dev/null; then
  log_skip "omasnap already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing omasnap runtime dependencies..."
omarchy pkg add qt6-base layer-shell-qt wayland wayland-protocols grim wl-clipboard tesseract tesseract-data-eng tesseract-data-tha
