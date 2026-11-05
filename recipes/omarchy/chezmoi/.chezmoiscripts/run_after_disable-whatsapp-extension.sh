#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

extension="/usr/share/omarchy/default/chromium/extensions/whatsapp-slim"
configs=(
  "$HOME/.config/chromium-flags.conf"
  "$HOME/.config/chrome-flags.conf"
  "$HOME/.config/microsoft-edge-stable-flags.conf"
  "$HOME/.config/brave-flags.conf"
  "$HOME/.config/brave-origin-flags.conf"
)

set -eo pipefail

for config in "${configs[@]}"; do
  [[ -f $config ]] || continue
  tmp=$(mktemp "${config}.XXXXXX")

  if ! awk -F, -v extension="$extension" '
    /^--load-extension=/ {
      prefix = "--load-extension="
      value = substr($0, length(prefix) + 1)
      count = split(value, paths, ",")
      kept = ""
      for (i = 1; i <= count; i++) {
        if (paths[i] != extension) {
          kept = kept (kept == "" ? "" : ",") paths[i]
        }
      }
      if (kept != "") print prefix kept
      next
    }
    { print }
  ' "$config" >"$tmp"; then
    rm -f "$tmp"
    log_error "Could not filter WhatsApp extension from $config"
    exit 1
  fi

  if ! cmp -s "$config" "$tmp"; then
    chmod --reference="$config" "$tmp"
    mv "$tmp" "$config"
    log_info "Disabled Omarchy's WhatsApp Chromium extension in $(basename "$config")"
  else
    rm "$tmp"
    log_skip "WhatsApp extension already disabled in $(basename "$config")"
  fi
done
