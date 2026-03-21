#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v ttyd &>/dev/null; then
  log_skip "ttyd already installed"
  exit 0
fi

_install() {
  set -e
  log_info "Installing ttyd..."
  # https://github.com/tsl0922/ttyd/releases
  local arch
  arch="$(uname -m)"
  case "$arch" in
  x86_64) arch="x86_64" ;;
  aarch64 | arm64) arch="aarch64" ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    return 1
    ;;
  esac
  mkdir -p "$HOME/.local/bin"
  wget -qO "$HOME/.local/bin/ttyd" \
    "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.${arch}"
  chmod +x "$HOME/.local/bin/ttyd"
}

if ! _install; then
  log_error "Failed to install ttyd (network unavailable?)"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
