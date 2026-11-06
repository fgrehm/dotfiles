#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/.chezmoiscripts/run_once_after_000-disable-openssh-agent.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export XDG_RUNTIME_DIR="$tmp/runtime"
export CHEZMOI_SOURCE_DIR="$tmp/chezmoi-source"
export SYSTEMCTL_LOG="$tmp/systemctl.log"
export MOCK_AGENTS_ACTIVE=1
export MOCK_SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
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
  '--user is-active --quiet gcr-ssh-agent.socket'|'--user is-enabled --quiet gcr-ssh-agent.socket')
    [[ ${MOCK_AGENTS_ACTIVE:-0} == 1 ]]
    ;;
  '--user show-environment')
    printf 'SSH_AUTH_SOCK=%s\n' "$MOCK_SSH_AUTH_SOCK"
    ;;
  *) exit 0 ;;
esac
SYSTEMCTL
chmod +x "$tmp/bin/systemctl"

legacy="$HOME/.config/environment.d/90-gcr-ssh-agent.conf"
printf 'SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh\n' >"$legacy"
"$script"
[[ ! -e $legacy ]] || {
  printf 'FAIL: managed GCR environment file was not removed\n' >&2
  exit 1
}
grep -Fqx -- '--user disable --now gcr-ssh-agent.socket' "$SYSTEMCTL_LOG" || {
  printf 'FAIL: GCR agent socket was not disabled\n' >&2
  exit 1
}
if grep -Fqx -- '--user unset-environment SSH_AUTH_SOCK' "$SYSTEMCTL_LOG"; then
  printf 'FAIL: OpenSSH SSH_AUTH_SOCK was cleared\n' >&2
  exit 1
fi
if grep -Fqx -- '--user disable --now ssh-agent.socket' "$SYSTEMCTL_LOG" ||
  grep -Fqx -- '--user stop ssh-agent.service' "$SYSTEMCTL_LOG"; then
  printf 'FAIL: cleanup altered the OpenSSH socket or service\n' >&2
  exit 1
fi

# If the manager still names GCR, clear only that stale value.
: >"$SYSTEMCTL_LOG"
export MOCK_SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
"$script"
grep -Fqx -- '--user unset-environment SSH_AUTH_SOCK' "$SYSTEMCTL_LOG" || {
  printf 'FAIL: stale GCR SSH_AUTH_SOCK was not cleared\n' >&2
  exit 1
}

# Customized GCR configuration is preserved.
printf 'SSH_AUTH_SOCK=/custom/socket\n' >"$legacy"
export MOCK_AGENTS_ACTIVE=0
: >"$SYSTEMCTL_LOG"
"$script"
grep -Fqx 'SSH_AUTH_SOCK=/custom/socket' "$legacy" || {
  printf 'FAIL: customized GCR environment file was removed\n' >&2
  exit 1
}

printf 'PASS: GCR cleanup preserves the OpenSSH socket and clears only stale GCR environment\n'
