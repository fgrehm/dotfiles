#!/usr/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

set -eo pipefail

legacy_openssh_env="$HOME/.config/environment.d/ssh-agent.conf"
if [[ -f $legacy_openssh_env ]]; then
  if [[ $(wc -l <"$legacy_openssh_env") -eq 3 ]] &&
    grep -Fqx 'SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket' "$legacy_openssh_env" &&
    grep -Fqx 'SSH_ASKPASS=/usr/lib/seahorse/ssh-askpass' "$legacy_openssh_env" &&
    grep -Fqx 'SSH_ASKPASS_REQUIRE=prefer' "$legacy_openssh_env"; then
    rm -- "$legacy_openssh_env"
    log_info "Removed the legacy dotfiles OpenSSH agent environment file"
  else
    log_skip "Leaving customized SSH agent environment file untouched: $legacy_openssh_env"
  fi
fi

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

if systemctl --user is-active --quiet ssh-agent.socket ||
  systemctl --user is-enabled --quiet ssh-agent.socket; then
  log_info "Disabling the previously managed OpenSSH agent socket..."
  systemctl --user disable --now ssh-agent.socket
  systemctl --user stop ssh-agent.service 2>/dev/null || true
else
  log_skip "OpenSSH agent socket is already disabled"
fi
if systemctl --user is-active --quiet gcr-ssh-agent.socket ||
  systemctl --user is-enabled --quiet gcr-ssh-agent.socket; then
  log_info "Disabling the Omarchy GCR SSH agent socket..."
  systemctl --user disable --now gcr-ssh-agent.socket
  systemctl --user stop gcr-ssh-agent.service 2>/dev/null || true
else
  log_skip "GCR SSH agent socket is already disabled"
fi
systemctl --user unset-environment SSH_AUTH_SOCK || true
