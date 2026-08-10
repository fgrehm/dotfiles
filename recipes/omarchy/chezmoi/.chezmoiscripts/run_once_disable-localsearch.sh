#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

# Disable the GNOME filesystem indexer (localsearch, formerly tracker3-miners).
# It's a hard dependency of nautilus, but nothing on Omarchy consumes its index
# (Walker's file search is self-contained). It burns CPU/RAM indexing $HOME.
# Masking prevents the service from starting on login; the autostart desktop
# file (private_dot_config/autostart/localsearch-3.desktop) is belt-and-suspenders
# against DBus activation by nautilus.

SERVICES=(
  localsearch-3.service
  localsearch-control-3.service
  localsearch-writeback-3.service
  tinysparql-xdg-portal-3.service
)

if systemctl --user is-enabled localsearch-3.service 2>/dev/null | grep -q masked; then
  log_skip "localsearch already disabled"
  exit 0
fi

set -eo pipefail

log_info "Masking localsearch services..."
systemctl --user mask "${SERVICES[@]}"
systemctl --user stop localsearch-3.service
