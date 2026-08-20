#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

export PATH="$HOME/.local/bin:$PATH"

BASH_DIR="$HOME/.local/share/bash-completion/completions"
ZSH_DIR="$HOME/.zsh/completions"
mkdir -p "$BASH_DIR" "$ZSH_DIR"

if command -v lazygit &>/dev/null; then
  log_info "Generating lazygit completions..."
  if ! lazygit completion bash >"$BASH_DIR/lazygit"; then
    log_error "Failed to generate lazygit bash completions (non-fatal)"
  fi
  if ! lazygit completion zsh >"$ZSH_DIR/_lazygit"; then
    log_error "Failed to generate lazygit zsh completions (non-fatal)"
  fi
else
  log_skip "lazygit not found, skipping completions"
fi

if command -v gh &>/dev/null; then
  log_info "Generating gh completions..."
  GH_CMD=(gh)
  # Omarchy's gh command is a mise shim, which prints tool-selection status
  # unless invoked through quiet mise. That status would corrupt the completion
  # files written below.
  if command -v mise &>/dev/null && mise which gh &>/dev/null; then
    GH_CMD=(mise exec --quiet gh -- gh)
  fi
  if ! "${GH_CMD[@]}" completion -s bash >"$BASH_DIR/gh"; then
    log_error "Failed to generate gh bash completions (non-fatal)"
  fi
  if ! "${GH_CMD[@]}" completion -s zsh >"$ZSH_DIR/_gh"; then
    log_error "Failed to generate gh zsh completions (non-fatal)"
  fi
else
  log_skip "gh not found, skipping completions"
fi
