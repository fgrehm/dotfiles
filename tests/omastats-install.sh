#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/.chezmoiscripts/run_once_after_enable-omastats.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export CHEZMOI_SOURCE_DIR="$tmp/source"
export OMARCHY_LOG="$tmp/omarchy-calls"
export PATH="$tmp/bin:$PATH"
mkdir -p "$CHEZMOI_SOURCE_DIR/scripts" "$tmp/bin"
cat >"$CHEZMOI_SOURCE_DIR/scripts/ui.bash" <<'UI'
log_info() { :; }
log_skip() { :; }
log_error() { printf 'ERROR: %s\n' "$*" >&2; }
UI
cat >"$tmp/bin/jq" <<'JQ'
#!/usr/bin/env bash
case "$*" in
  *'and .enabled'*) exit 1 ;;
  *'any(.[]; .id == $id)'*) exit 1 ;;
  *) exit 2 ;;
esac
JQ
cat >"$tmp/bin/omarchy" <<'OMARCHY'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$OMARCHY_LOG"
if [[ $* == 'plugin list --json' ]]; then
  printf '[]\n'
fi
OMARCHY
chmod +x "$tmp/bin/jq" "$tmp/bin/omarchy"

"$script"
grep -Fqx 'plugin add https://github.com/crmne/omastats.git --enable --yes' "$OMARCHY_LOG" || {
  printf 'FAIL: plugin add must wait for discovery and enable the plugin\n' >&2
  exit 1
}
grep -Fqx 'plugin enable crmne.omastats --section right' "$OMARCHY_LOG" || {
  printf 'FAIL: OmaStats was not placed in the right bar section\n' >&2
  exit 1
}

printf 'PASS: OmaStats install waits for discovery, enables, then places the widget on the right\n'
