#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v slack &>/dev/null; then
  log_skip "Slack already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing Slack..."
omarchy pkg aur add slack-desktop

# xdg-desktop-portal-wlr enables Wayland screen sharing (wlroots/Hyprland).
if ! pacman -Q xdg-desktop-portal-wlr &>/dev/null; then
  log_info "Installing xdg-desktop-portal-wlr for Wayland screen sharing..."
  omarchy pkg add xdg-desktop-portal-wlr
fi
