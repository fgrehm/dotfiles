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
case "$1" in
  whoami)
    [[ -f $OP_LOGGED_IN ]]
    ;;
  signin)
    [[ ${OP_SIGNIN_FAIL:-0} != 1 ]] || exit 1
    touch "$OP_LOGGED_IN"
    printf ':\n'
    ;;
  read)
    [[ -f $OP_LOGGED_IN ]] || exit 1
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
export OP_LOGGED_IN="$tmp/op-logged-in"
bash "$rendered"

signin_line=$(grep -n '^signin$' "$OP_LOG" | cut -d: -f1)
verify_line=$(grep -n '^whoami$' "$OP_LOG" | tail -1 | cut -d: -f1)
read_line=$(grep -n '^read op://Keys/SSH/id_ed25519$' "$OP_LOG" | cut -d: -f1)
[[ -n $signin_line && -n $verify_line && -n $read_line ]] || {
  printf 'FAIL: expected sign-in, authentication verification, and key read calls\n' >&2
  exit 1
}
((signin_line < verify_line && verify_line < read_line)) || {
  printf 'FAIL: SSH attachments were read before authentication was verified\n' >&2
  exit 1
}
[[ $(stat -c '%a' "$HOME/.ssh/id_ed25519") == 600 ]] || {
  printf 'FAIL: private key permissions were not restricted\n' >&2
  exit 1
}

export HOME="$tmp/failure-home"
export OP_LOG="$tmp/op-failure.log"
export OP_LOGGED_IN="$tmp/op-never-logged-in"
export OP_SIGNIN_FAIL=1
if bash "$rendered" >/dev/null 2>&1; then
  printf 'FAIL: key setup succeeded when 1Password sign-in failed\n' >&2
  exit 1
fi
if grep -q '^read ' "$OP_LOG"; then
  printf 'FAIL: key attachments were read after failed authentication\n' >&2
  exit 1
fi

printf 'PASS: 1Password key setup authenticates before reads and fails safely when signed out\n'
