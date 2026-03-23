#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v vhs &>/dev/null; then
  log_skip "vhs already installed"
  exit 0
fi

_install() {
  set -eo pipefail
  log_info "Installing vhs..."
  # https://github.com/charmbracelet/vhs/releases
  local arch
  arch="$(uname -m)"
  case "$arch" in
  x86_64) arch="x86_64" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    echo "Unsupported architecture: $arch" >&2
    return 1
    ;;
  esac
  local version
  version=$(wget -qO- "https://api.github.com/repos/charmbracelet/vhs/releases/latest" |
    grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
  mkdir -p "$HOME/.local/bin"
  local tmp
  tmp="$(mktemp -d)"
  wget -qO- "https://github.com/charmbracelet/vhs/releases/download/v${version}/vhs_${version}_Linux_${arch}.tar.gz" |
    tar xz -C "$tmp" --strip-components=1
  mv "$tmp/vhs" "$HOME/.local/bin/vhs"
  rm -rf "$tmp"
}

if ! _install; then
  log_error "Failed to install vhs (network unavailable?)"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
