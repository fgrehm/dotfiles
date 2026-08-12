#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

# Remove unwanted omarchy webapps (they share the main browser profile).
# Collect the installed ones, then remove them in a single call so
# omarchy-webapp-remove restarts the app launcher once (not per app), avoiding
# systemd's start-limit on rapid restarts.
APPS_TO_REMOVE=()
for app in "Basecamp" "Discord" "Fizzy" "Google Contacts" "Zoom" "HEY" "Google Messages" "Google Photos" "WhatsApp"; do
  if [ -f "$HOME/.local/share/applications/$app.desktop" ]; then
    APPS_TO_REMOVE+=("$app")
  else
    log_skip "webapp not installed: $app"
  fi
done

if [ "${#APPS_TO_REMOVE[@]}" -gt 0 ]; then
  log_info "Removing webapps: ${APPS_TO_REMOVE[*]}"
  if ! omarchy-webapp-remove "${APPS_TO_REMOVE[@]}"; then
    log_error "Failed to remove webapps (non-fatal)"
  fi
else
  log_skip "no webapps to remove"
fi
