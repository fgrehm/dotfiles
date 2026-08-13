#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# Enable the stock OpenSSH ssh-agent user socket so SSH keys are cached for
# the session. The socket is the real trigger (the service is `indirect` --
# it starts on-demand when the socket accepts a connection). Enabling the
# service alone reports `indirect` and passes `is-enabled` even when the
# socket is disabled, so we must check/enable the socket specifically.
# SSH_AUTH_SOCK is pointed at the socket via environment.d/ssh-agent.conf.
if systemctl --user is-enabled ssh-agent.socket >/dev/null 2>&1; then
  log_skip "ssh-agent.socket already enabled"
  exit 0
fi

set -eo pipefail

log_info "Enabling ssh-agent.socket..."
systemctl --user enable --now ssh-agent.socket
