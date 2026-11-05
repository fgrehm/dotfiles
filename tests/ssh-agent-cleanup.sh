#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/.chezmoiscripts/run_once_after_000-disable-openssh-agent.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export CHEZMOI_SOURCE_DIR="$tmp/chezmoi-source"
export SYSTEMCTL_LOG="$tmp/systemctl.log"
export MOCK_AGENTS_ACTIVE=1
export PATH="$tmp/bin:$PATH"
mkdir -p "$HOME/.config/environment.d" "$CHEZMOI_SOURCE_DIR/scripts" "$tmp/bin"
cat >"$CHEZMOI_SOURCE_DIR/scripts/ui.bash" <<'UI'
log_info() { :; }
log_skip() { :; }
log_error() { printf 'ERROR: %s\n' "$*" >&2; }
UI
cat >"$tmp/bin/systemctl" <<'SYSTEMCTL'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
case "$*" in
  '--user is-active --quiet ssh-agent.socket'|'--user is-enabled --quiet ssh-agent.socket'|\
    '--user is-active --quiet gcr-ssh-agent.socket'|'--user is-enabled --quiet gcr-ssh-agent.socket')
    [[ ${MOCK_AGENTS_ACTIVE:-0} == 1 ]]
    ;;
  *) exit 0 ;;
esac
SYSTEMCTL
chmod +x "$tmp/bin/systemctl"

legacy="$HOME/.config/environment.d/ssh-agent.conf"
cat >"$legacy" <<'CONFIG'
SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket
SSH_ASKPASS=/usr/lib/seahorse/ssh-askpass
SSH_ASKPASS_REQUIRE=prefer
CONFIG
gcr_env="$HOME/.config/environment.d/90-gcr-ssh-agent.conf"
printf 'SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh\n' >"$gcr_env"
"$script"
[[ ! -e $legacy && ! -e $gcr_env ]] || {
  printf 'FAIL: managed SSH agent environment files were not removed\n' >&2
  exit 1
}
grep -Fqx -- '--user disable --now ssh-agent.socket' "$SYSTEMCTL_LOG" || {
  printf 'FAIL: OpenSSH agent socket was not disabled\n' >&2
  exit 1
}
grep -Fqx -- '--user disable --now gcr-ssh-agent.socket' "$SYSTEMCTL_LOG" || {
  printf 'FAIL: GCR agent socket was not disabled\n' >&2
  exit 1
}
grep -Fqx -- '--user unset-environment SSH_AUTH_SOCK' "$SYSTEMCTL_LOG" || {
  printf 'FAIL: systemd user environment was not cleared\n' >&2
  exit 1
}

printf 'SSH_AUTH_SOCK=/custom/socket\n' >"$legacy"
export MOCK_AGENTS_ACTIVE=0
"$script"
grep -Fqx 'SSH_AUTH_SOCK=/custom/socket' "$legacy" || {
  printf 'FAIL: customized SSH agent environment file was removed\n' >&2
  exit 1
}

printf 'PASS: legacy OpenSSH/GCR configuration is removed safely and custom config is preserved\n'
