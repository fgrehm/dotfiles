#!/bin/sh
# One-liner dotfiles setup: installs chezmoi + chezmoi-recipes, clones this
# repo, builds the overlay, initializes chezmoi, and applies.
#
# Usage:
# Run this script from a local clone after reviewing it. All arguments are
# forwarded to chezmoi init.

set -eu

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

_log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
_die() {
  printf '\033[1;31merror: %s\033[0m\n' "$*" >&2
  exit 1
}

# Download a URL to stdout (wget preferred, curl fallback)
_download() {
  if command -v wget >/dev/null 2>&1; then
    wget -qO- "$1"
  else
    curl -fsSL "$1"
  fi
}

[ "$(uname -s)" = "Linux" ] || _die "only Linux is supported"
if ! command -v git >/dev/null 2>&1; then
  if command -v pacman >/dev/null 2>&1; then
    _die "git is required but not installed (pacman -S git)"
  else
    _die "git is required but not installed (apt-get install git)"
  fi
fi

case "$(uname -m)" in
x86_64) ARCH=amd64 ;;
aarch64 | arm64) ARCH=arm64 ;;
*) _die "unsupported architecture: $(uname -m)" ;;
esac

mkdir -p "$BIN_DIR"
case ":${PATH:-}:" in
*":$BIN_DIR:"*) ;;
*) export PATH="$BIN_DIR${PATH:+:$PATH}" ;;
esac

CHEZMOI_VERSION="2.72.0"
CHEZMOI_RECIPES_VERSION="0.6.0"

case "$ARCH" in
amd64)
  CHEZMOI_SHA256="0d6665b96c527d57fdc562bf19e808f80f48c2d977062c03e3e65c6b09eafbce"
  CHEZMOI_RECIPES_SHA256="1b6f6015a51a0f547a6187bc2905f820412a4365217a7f800a4e17e214fa75d2"
  ;;
arm64)
  CHEZMOI_SHA256="e79a27621256390f03166d3965e6a1946f983a096c4d90f02c43d2aa5b563728"
  CHEZMOI_RECIPES_SHA256="e3466a572795fa716648e1b66f5ffda4823f0b2de0c59480969cbd7d9f5b231c"
  ;;
esac

_verify_sha256() {
  expected="$1" file="$2"
  printf '%s  %s\n' "$expected" "$file" | sha256sum -c --status || _die "checksum mismatch for $file"
}

# Install chezmoi from a pinned, verified GitHub release.
if ! command -v chezmoi >/dev/null 2>&1; then
  _log "Installing chezmoi v$CHEZMOI_VERSION"
  tmp=$(mktemp) || _die "failed to create temporary file"
  trap 'rm -f "$tmp"' EXIT
  _download "https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOI_VERSION}/chezmoi_${CHEZMOI_VERSION}_linux_${ARCH}.tar.gz" >"$tmp" || _die "failed to download chezmoi"
  _verify_sha256 "$CHEZMOI_SHA256" "$tmp"
  tar xzf "$tmp" -C "$BIN_DIR" chezmoi || _die "failed to extract chezmoi"
  rm -f "$tmp"
  trap - EXIT
fi

# Install chezmoi-recipes from a pinned, verified GitHub release.
if ! command -v chezmoi-recipes >/dev/null 2>&1; then
  _log "Installing chezmoi-recipes v$CHEZMOI_RECIPES_VERSION"
  tmp=$(mktemp) || _die "failed to create temporary file"
  trap 'rm -f "$tmp"' EXIT
  _download "https://github.com/fgrehm/chezmoi-recipes/releases/download/v${CHEZMOI_RECIPES_VERSION}/chezmoi-recipes_linux_${ARCH}.tar.gz" >"$tmp" || _die "failed to download chezmoi-recipes"
  _verify_sha256 "$CHEZMOI_RECIPES_SHA256" "$tmp"
  tar xzf "$tmp" -C "$BIN_DIR" || _die "failed to extract chezmoi-recipes"
  rm -f "$tmp"
  trap - EXIT
fi

REPO_URL='https://github.com/fgrehm/dotfiles.git'
SOURCE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi"

# If run from within the repo, use it directly instead of cloning
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/.chezmoiroot" ]; then
  _log "Running from local repo at $SCRIPT_DIR"
  SOURCE_DIR="$SCRIPT_DIR"
elif [ ! -d "$SOURCE_DIR/.git" ]; then
  _log "Cloning $REPO_URL"
  git clone "$REPO_URL" "$SOURCE_DIR"
else
  _log "Dotfiles already cloned at $SOURCE_DIR"
fi

# Build compiled-home/ so chezmoi can find the config template
_log "Building overlay"
(cd "$SOURCE_DIR" && chezmoi-recipes overlay --recipes-dir "$SOURCE_DIR/recipes")

# Initialize chezmoi (processes config template, prompts for user data)
_log "Initializing chezmoi"
chezmoi init --source "$SOURCE_DIR" "$@"

# Apply dotfiles
_log "Applying dotfiles"
exec chezmoi apply
