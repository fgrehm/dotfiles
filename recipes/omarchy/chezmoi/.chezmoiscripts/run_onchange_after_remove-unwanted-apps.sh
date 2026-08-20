#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

# Remove unwanted omarchy webapps (they share the main browser profile).
for app in "Basecamp" "Discord" "Fizzy" "Google Contacts" "Zoom" "HEY" "Google Messages" "Google Photos" "WhatsApp"; do
  if [ -f "$HOME/.local/share/applications/$app.desktop" ]; then
    log_info "Removing webapp: $app"
    if ! omarchy-webapp-remove "$app"; then
      log_error "Failed to remove webapp: $app (non-fatal)"
    fi
  else
    log_skip "webapp not installed: $app"
  fi
done
