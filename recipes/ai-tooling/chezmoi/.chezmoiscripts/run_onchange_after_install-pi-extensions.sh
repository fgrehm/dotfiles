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

for extension in npm:pi-web-access npm:pi-ollama-cloud; do
  log_info "Installing Pi extension: $extension"
  if ! pi install "$extension"; then
    log_error "Failed to install Pi extension: $extension (non-fatal)"
  fi
done
