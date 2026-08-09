#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# Enable the stock OpenSSH ssh-agent user service (and its socket) so SSH keys
# are cached for the session. SSH_AUTH_SOCK is pointed at the socket via
# environment.d/ssh-agent.conf.
if systemctl --user is-enabled ssh-agent.service >/dev/null 2>&1; then
  log_skip "ssh-agent.service already enabled"
  exit 0
fi

set -eo pipefail

log_info "Enabling ssh-agent.service..."
systemctl --user enable --now ssh-agent.service
