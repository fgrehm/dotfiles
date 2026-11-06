#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
template="$root/recipes/1password/chezmoi/.chezmoiscripts/run_onchange_after_setup-ssh-keys.sh.tmpl"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

config="$tmp/empty.toml"
: >"$config"
rendered="$tmp/setup-ssh-keys.sh"
chezmoi --config "$config" --source "$root/recipes/1password/chezmoi" execute-template \
  --override-data '{"onepasswordSshVault":"Keys","onepasswordSshItem":"SSH"}' \
  --left-delimiter '# {{' --right-delimiter '}}' --file "$template" >"$rendered"
bash -n "$rendered"

mkdir -p "$tmp/bin" "$tmp/source/scripts"
cat >"$tmp/source/scripts/ui.bash" <<'UI'
log_info() { :; }
log_skip() { :; }
log_error() { printf 'ERROR: %s\n' "$*" >&2; }
UI
cat >"$tmp/bin/op" <<'OP'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$OP_LOG"
case "$*" in
  'vault list --format=json')
    [[ ${OP_VAULT_ACCESS:-0} == 1 ]]
    ;;
  'read op://Keys/SSH/id_ed25519'|'read op://Keys/SSH/id_ed25519.pub'|'read op://Keys/SSH/id_ed25519-sign'|'read op://Keys/SSH/id_ed25519-sign.pub')
    [[ ${OP_VAULT_ACCESS:-0} == 1 ]] || exit 1
    printf 'key fixture\n'
    ;;
  *) exit 2 ;;
esac
OP
chmod +x "$tmp/bin/op"
export CHEZMOI_SOURCE_DIR="$tmp/source"
export PATH="$tmp/bin:$PATH"
export HOME="$tmp/success-home"
export OP_LOG="$tmp/op-success.log"
export OP_VAULT_ACCESS=1
bash "$rendered"

vault_line=$(grep -n '^vault list --format=json$' "$OP_LOG" | cut -d: -f1)
read_line=$(grep -n '^read op://Keys/SSH/id_ed25519$' "$OP_LOG" | cut -d: -f1)
[[ -n $vault_line && -n $read_line ]] || {
  printf 'FAIL: expected vault access check and key read calls\n' >&2
  exit 1
}
((vault_line < read_line)) || {
  printf 'FAIL: SSH attachments were read before vault access was verified\n' >&2
  exit 1
}
if grep -Eq '^(whoami|signin)( |$)' "$OP_LOG"; then
  printf 'FAIL: setup unexpectedly relied on CLI sign-in state\n' >&2
  exit 1
fi
[[ $(stat -c '%a' "$HOME/.ssh/id_ed25519") == 600 ]] || {
  printf 'FAIL: private key permissions were not restricted\n' >&2
  exit 1
}

export HOME="$tmp/failure-home"
export OP_LOG="$tmp/op-failure.log"
export OP_VAULT_ACCESS=0
if bash "$rendered" >/dev/null 2>&1; then
  printf 'FAIL: key setup succeeded without vault access\n' >&2
  exit 1
fi
if grep -q '^read ' "$OP_LOG"; then
  printf 'FAIL: key attachments were read without verified vault access\n' >&2
  exit 1
fi

printf 'PASS: SSH key setup checks desktop-integrated vault access before reading attachments\n'
