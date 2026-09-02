#!/bin/bash
# Shared privilege detection for install scripts.

setup_sudo() {
  if [ "$(id -u)" -ne 0 ] && command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    SUDO="sudo"
  else
    SUDO=""
  fi
}

can_install_system_packages() {
  [ "$(id -u)" -eq 0 ] || [ -n "${SUDO:-}" ]
}
