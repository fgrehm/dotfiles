#!/bin/env bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

export PATH="$HOME/.local/bin:$PATH"

if ! command -v gh &>/dev/null; then
  log_skip "gh not found, skipping extensions"
  exit 0
fi

# gh-pr-review pinned to v1.6.2
# Changing the pin above triggers a re-run via run_onchange_.
if gh extension list 2>/dev/null | grep -q "agynio/gh-pr-review"; then
  gh extension remove gh-pr-review
fi
log_info "Installing gh-pr-review..."
if ! gh extension install agynio/gh-pr-review --pin v1.6.2; then
  log_error "Failed to install gh-pr-review extension (non-fatal)"
fi
