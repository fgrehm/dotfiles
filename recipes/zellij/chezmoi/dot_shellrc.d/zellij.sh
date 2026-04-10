# shellcheck shell=bash
# Zellij helpers.

# Attach to a zellij session, creating it if needed.
zac() {
  zellij attach --create "$1"
}
