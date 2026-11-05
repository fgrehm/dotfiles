#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/.chezmoiscripts/run_after_disable-whatsapp-extension.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export CHEZMOI_SOURCE_DIR="$tmp/chezmoi-source"
mkdir -p "$HOME/.config" "$CHEZMOI_SOURCE_DIR/scripts"
cat >"$CHEZMOI_SOURCE_DIR/scripts/ui.bash" <<'UI'
log_info() { :; }
log_skip() { :; }
log_error() { printf 'ERROR: %s\n' "$*" >&2; }
UI
cat >"$HOME/.config/brave-flags.conf" <<'FLAGS'
--ozone-platform=wayland
--load-extension=/usr/share/omarchy/default/chromium/extensions/copy-url,/usr/share/omarchy/default/chromium/extensions/whatsapp-slim,/usr/share/omarchy/default/chromium/extensions/yt-dlp
FLAGS
cat >"$HOME/.config/chromium-flags.conf" <<'FLAGS'
--load-extension=/usr/share/omarchy/default/chromium/extensions/whatsapp-slim
FLAGS

"$script" >/dev/null
before=$(sha256sum "$HOME/.config/brave-flags.conf" "$HOME/.config/chromium-flags.conf")
"$script" >/dev/null
after=$(sha256sum "$HOME/.config/brave-flags.conf" "$HOME/.config/chromium-flags.conf")
[[ $before == "$after" ]] || {
  printf 'FAIL: second run changed already-clean browser flags\n' >&2
  exit 1
}

grep -qx -- '--load-extension=/usr/share/omarchy/default/chromium/extensions/copy-url,/usr/share/omarchy/default/chromium/extensions/yt-dlp' "$HOME/.config/brave-flags.conf" || {
  printf 'FAIL: did not preserve non-WhatsApp Brave extensions\n' >&2
  exit 1
}
grep -qx -- '--ozone-platform=wayland' "$HOME/.config/brave-flags.conf" || {
  printf 'FAIL: did not preserve other Brave flags\n' >&2
  exit 1
}
if grep -q 'whatsapp-slim' "$HOME/.config/brave-flags.conf" "$HOME/.config/chromium-flags.conf"; then
  printf 'FAIL: WhatsApp extension still appears in browser flags\n' >&2
  exit 1
fi
if grep -q '^--load-extension=' "$HOME/.config/chromium-flags.conf"; then
  printf 'FAIL: empty extension flag was not removed\n' >&2
  exit 1
fi

printf 'PASS: WhatsApp extension removed while other browser flags are preserved\n'
