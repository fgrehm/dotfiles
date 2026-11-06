#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

gcr_env="$HOME/.config/environment.d/90-gcr-ssh-agent.conf"
if [[ -f $gcr_env ]]; then
  if [[ $(wc -l <"$gcr_env") -eq 1 ]] &&
    grep -Fqx 'SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh' "$gcr_env"; then
    rm -- "$gcr_env"
    log_info "Removed the Omarchy GCR SSH agent environment file"
  else
    log_skip "Leaving customized GCR SSH agent environment file untouched: $gcr_env"
  fi
fi

if systemctl --user is-active --quiet gcr-ssh-agent.socket ||
  systemctl --user is-enabled --quiet gcr-ssh-agent.socket; then
  log_info "Disabling the Omarchy GCR SSH agent socket..."
  systemctl --user disable --now gcr-ssh-agent.socket
  systemctl --user stop gcr-ssh-agent.service 2>/dev/null || true
else
  log_skip "GCR SSH agent socket is already disabled"
fi

# Omarchy's GCR removal flow can leave its socket in the user manager environment.
# Only clear that value when it names the GCR socket, preserving OpenSSH for containers.
if systemctl --user show-environment | grep -Fqx "SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh"; then
  systemctl --user unset-environment SSH_AUTH_SOCK || true
fi
