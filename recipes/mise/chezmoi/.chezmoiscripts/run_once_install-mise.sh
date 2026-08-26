#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v mise &>/dev/null; then
  log_skip "mise already installed"
  exit 0
fi

set -eo pipefail

VERSION="2026.8.14"

case "$(uname -m)" in
x86_64)
  ARCH="x64"
  SHA256="7cd12d6002d5b3c83a89cad79023712faf2a36f9e8b2ee2061dac5135b3de0ed"
  ;;
aarch64 | arm64)
  ARCH="arm64"
  SHA256="bc2c447a7e498b0bed0a421cc2101b407fef09a3195670d35a4aa3f43cd868a1"
  ;;
*)
  log_error "Unsupported architecture: $(uname -m)"
  exit 1
  ;;
esac

log_info "Installing mise v$VERSION..."
mkdir -p "$HOME/.local/bin"
ARCHIVE="$(mktemp)"
trap 'rm -f "$ARCHIVE"' EXIT
URL="https://github.com/jdx/mise/releases/download/v${VERSION}/mise-v${VERSION}-linux-${ARCH}"

if command -v wget &>/dev/null; then
  wget -qO "$ARCHIVE" "$URL"
else
  curl -fsSL "$URL" -o "$ARCHIVE"
fi

if ! printf '%s  %s\n' "$SHA256" "$ARCHIVE" | sha256sum -c --status; then
  log_error "mise binary checksum mismatch, aborting"
  exit 1
fi

install -m 755 "$ARCHIVE" "$HOME/.local/bin/mise"
