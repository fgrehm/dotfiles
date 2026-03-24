# shellcheck shell=bash
# Zellij helpers.

# Attach to a zellij session (creating it if needed) with the zellaude layout.
zac() {
  zellij attach --create "$1" options --default-layout zellaude
}
