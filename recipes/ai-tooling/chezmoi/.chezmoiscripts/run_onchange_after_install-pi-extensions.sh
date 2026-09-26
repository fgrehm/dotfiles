#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if ! command -v pi &>/dev/null; then
  log_skip "Pi not found, skipping Pi extensions"
  exit 0
fi

# Pi manages extension installation and settings itself. Keep these machine-local
# settings out of the chezmoi source while making the desired extensions available
# whenever Pi is present.
settings="$HOME/.pi/agent/settings.json"

# Pin versions so a fresh machine gets a known-good set, but never downgrade or
# reinstall an extension the machine already has. Match on the package name, not
# the pinned version, so a newer machine-local version is left untouched.
for extension in npm:pi-web-access@0.27.0 npm:pi-ollama-cloud@0.10.0; do
  package_name="${extension%@*}"
  if [ -f "$settings" ] && jq -e --arg name "$package_name" \
    '.packages | any(.[]; (if type == "string" then . else .source end) as $s | $s == $name or ($s | startswith($name + "@")))' \
    "$settings" >/dev/null 2>&1; then
    log_skip "Pi extension already configured: $package_name"
    continue
  fi

  log_info "Installing Pi extension: $extension"
  if ! pi install "$extension"; then
    log_error "Failed to install Pi extension: $extension (non-fatal)"
  fi
done
