#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$root/recipes/omarchy/chezmoi"
template="$source_dir/.chezmoiscripts/run_onchange_after_reload-xcompose.sh.tmpl"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/source/scripts" "$tmp/bin"
: >"$tmp/config.toml"
cp "$source_dir/private_dot_XCompose" "$tmp/source/private_dot_XCompose"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

# Keep stock Compose definitions, then override both cedilla sequences.
compose="$tmp/source/private_dot_XCompose"
grep -Fqx 'include "/usr/share/omarchy/default/xcompose"' "$compose" || fail "Omarchy Compose include missing"
grep -Fqx '<dead_acute> <c> : "ç" U00E7' "$compose" || fail "lowercase cedilla mapping missing"
grep -Fqx '<dead_acute> <C> : "Ç" U00C7' "$compose" || fail "uppercase cedilla mapping missing"

# Personal keyboard options must not add a second layout-switch shortcut.
input="$source_dir/private_dot_config/hypr/input.lua"
grep -Fq 'kb_options = "ctrl:nocaps"' "$input" || fail "Caps-as-Ctrl option changed"
if grep -q 'grp:' "$input"; then
  fail "custom layout-switch shortcut remains"
fi

render() {
  chezmoi --config "$tmp/config.toml" --source "$tmp/source" execute-template \
    --left-delimiter '# {{' --right-delimiter '}}' --file "$template"
}
render >"$tmp/reload.sh"
bash -n "$tmp/reload.sh"
grep -Fq "$(sha256sum "$compose" | cut -d' ' -f1)" "$tmp/reload.sh" || fail "Compose hash missing from reload script"
printf '\n# changed fixture\n' >>"$compose"
render >"$tmp/reload-changed.sh"
if cmp -s "$tmp/reload.sh" "$tmp/reload-changed.sh"; then
  fail "Compose changes do not trigger the onchange reload"
fi

cat >"$tmp/source/scripts/ui.bash" <<'UI'
log_info() { :; }
UI
cat >"$tmp/bin/omarchy" <<'OMARCHY'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$OMARCHY_LOG"
exit "${MOCK_EXIT:-0}"
OMARCHY
chmod +x "$tmp/bin/omarchy"
export CHEZMOI_SOURCE_DIR="$tmp/source" OMARCHY_LOG="$tmp/omarchy.log"
export PATH="$tmp/bin:$PATH"
bash "$tmp/reload.sh"
grep -Fqx 'restart xcompose' "$OMARCHY_LOG" || fail "reload did not call Omarchy's supported command"
if MOCK_EXIT=1 bash "$tmp/reload.sh"; then
  fail "reload failure was silently accepted"
fi

printf 'PASS: cedilla mappings, stock layout switching, and Compose reload trigger\n'
