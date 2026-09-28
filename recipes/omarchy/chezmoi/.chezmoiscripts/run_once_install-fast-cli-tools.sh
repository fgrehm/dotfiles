#!/usr/bin/env bash
# vim: ft=bash.gotmpl
# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

packages=(
  "zapfast-bin"
  "spotifast-bin"
)

missing=()
for pkg in "${packages[@]}"; do
  if ! pacman -Q "$pkg" &>/dev/null; then
    missing+=("$pkg")
  fi
done

if [[ ${#missing[@]} -eq 0 ]]; then
  log_skip "${packages[*]} already installed"
  exit 0
fi

set -eo pipefail

log_info "Installing from AUR: ${missing[*]}..."
omarchy pkg aur add "${missing[@]}"

for pkg in "${missing[@]}"; do
  if ! pacman -Q "$pkg" &>/dev/null; then
    log_error "$pkg did not install"
    exit 1
  fi
done
