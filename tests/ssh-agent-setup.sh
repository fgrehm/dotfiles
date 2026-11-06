#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/.chezmoiscripts/run_once_after_enable-gcr-ssh-agent.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export CHEZMOI_SOURCE_DIR="$tmp/source"
export OMARCHY_LOG="$tmp/omarchy.log"
export PATH="$tmp/bin:/usr/bin:/bin"
mkdir -p "$CHEZMOI_SOURCE_DIR/scripts" "$tmp/bin"
cat >"$CHEZMOI_SOURCE_DIR/scripts/ui.bash" <<'UI'
log_info() { :; }
log_skip() { :; }
log_error() { printf 'ERROR: %s\n' "$*" >&2; }
UI
cat >"$tmp/bin/omarchy" <<'OMARCHY'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$OMARCHY_LOG"
OMARCHY
chmod +x "$tmp/bin/omarchy"

"$script"
grep -Fqx 'setup security ssh agent' "$OMARCHY_LOG" || {
  printf 'FAIL: Omarchy GCR SSH agent setup command was not called\n' >&2
  exit 1
}

printf 'PASS: fresh-start setup enables Omarchy GCR SSH agent through its supported command\n'
