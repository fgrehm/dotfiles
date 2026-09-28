#!/usr/bin/env bash
# vim: ft=bash.gotmpl
# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"
# Refreshes the desktop entry database so the launcher picks up newly deployed
# .desktop files. Non-fatal: a stale database is not worth failing an apply over.
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

APPS_DIR="$HOME/.local/share/applications"

if ! command -v update-desktop-database &>/dev/null; then
  log_skip "update-desktop-database not found, skipping"
  exit 0
fi

if [[ ! -d "$APPS_DIR" ]]; then
  log_skip "$APPS_DIR does not exist, skipping"
  exit 0
fi

if ! update-desktop-database "$APPS_DIR"; then
  log_error "Failed to update the desktop entry database (non-fatal)"
fi
# vim: ft=bash.gotmpl
