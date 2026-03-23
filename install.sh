#!/bin/sh
# One-liner dotfiles setup: installs chezmoi + chezmoi-recipes, clones this
# repo, builds the overlay, initializes chezmoi, and applies.
#
# Usage:
#   sh -c "$(curl -fsSL <raw-url-to-this-file>)"
#
#   # Non-interactive (provide prompt values)
#   sh -c "$(curl -fsSL <raw-url-to-this-file>)" -- \
#     --promptString "Full name=Your Name" \
#     --promptString "Email=you@example.com"
#
# All arguments are forwarded to chezmoi init.

set -eu

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"

_log() { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
_die() { printf '\033[1;31merror: %s\033[0m\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Linux" ] || _die "only Linux is supported"

case "$(uname -m)" in
  x86_64)        ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) _die "unsupported architecture: $(uname -m)" ;;
esac

mkdir -p "$BIN_DIR"
export PATH="$BIN_DIR:$PATH"

# Install chezmoi
if ! command -v chezmoi >/dev/null 2>&1; then
  _log "Installing chezmoi"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$BIN_DIR"
fi

# Install chezmoi-recipes
if ! command -v chezmoi-recipes >/dev/null 2>&1; then
  _log "Installing chezmoi-recipes"
  curl -fsSL "https://github.com/fgrehm/chezmoi-recipes/releases/latest/download/chezmoi-recipes_linux_${ARCH}.tar.gz" \
    | tar xz -C "$BIN_DIR"
fi

REPO_URL='git@github.com:fgrehm/dotfiles.git'
SOURCE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/chezmoi"

# Clone dotfiles
if [ ! -d "$SOURCE_DIR/.git" ]; then
  _log "Cloning $REPO_URL"
  git clone "$REPO_URL" "$SOURCE_DIR"
else
  _log "Dotfiles already cloned at $SOURCE_DIR"
fi

# Build compiled-home/ so chezmoi can find the config template
_log "Building overlay"
chezmoi-recipes overlay --recipes-dir "$SOURCE_DIR/recipes"

# Initialize chezmoi (processes config template, prompts for user data)
_log "Initializing chezmoi"
chezmoi init --source "$SOURCE_DIR" "$@"

# Apply dotfiles
_log "Applying dotfiles"
exec chezmoi apply
