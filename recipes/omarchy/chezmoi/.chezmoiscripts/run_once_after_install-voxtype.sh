#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v voxtype &>/dev/null; then
  log_skip "Voxtype already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing Voxtype dictation..."
omarchy pkg add wtype voxtype-bin

# Config is deployed by chezmoi (private_dot_config/voxtype/config.toml),
# so no need to copy omarchy's default here.

log_info "Downloading Voxtype AI model (~150MB)..."
voxtype setup --download --no-post-install
# Enable GPU acceleration only when a discrete GPU is present. omarchy-hw-vulkan
# is too broad: integrated-only laptops (Intel/AMD iGPU) support Vulkan too, so
# it would enable GPU on machines with no dedicated card. A discrete GPU shows up
# as a second display controller in lspci (same heuristic as omarchy-hw-hybrid-gpu).
if (($(lspci 2>/dev/null | grep -cE 'VGA|3D|Display') >= 2)); then
  voxtype setup gpu --enable || true
fi
voxtype setup systemd

omarchy restart waybar
