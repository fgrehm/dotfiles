#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

export PATH="$HOME/.local/bin:$PATH"

if ! command -v prek &>/dev/null; then
  log_skip "prek not found, skipping prek completions"
  exit 0
fi

PREK_CMD=(prek)
# Omarchy's prek wrapper uses mise and may print tool-selection status.
if command -v mise &>/dev/null && mise which prek &>/dev/null; then
  PREK_CMD=(mise exec --quiet prek -- prek)
fi

BASH_DIR="$HOME/.local/share/bash-completion/completions"
ZSH_DIR="$HOME/.zsh/completions"
mkdir -p "$BASH_DIR" "$ZSH_DIR"

log_info "Generating prek completions..."
if ! COMPLETE=bash "${PREK_CMD[@]}" >"$BASH_DIR/prek"; then
  log_error "Failed to generate prek bash completions (non-fatal)"
fi
if ! COMPLETE=zsh "${PREK_CMD[@]}" >"$ZSH_DIR/_prek"; then
  log_error "Failed to generate prek zsh completions (non-fatal)"
fi
