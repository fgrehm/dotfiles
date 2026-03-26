#!/usr/bin/env bats
# Tests for the ai-tooling recipe.
#
# Run: bats test/unit/ai_tooling_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "ai-tooling"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "ai-tooling: overlay includes claude-code install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-claude-code.sh" ]
}

@test "ai-tooling: overlay includes pi-agent install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_after_install-pi-agent.sh" ]
}

@test "ai-tooling: overlay includes dot-ai install scripts" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai.sh" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai-private.sh" ]
}

@test "ai-tooling: overlay includes dotmem install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dotmem.sh.tmpl" ]
}

@test "ai-tooling: overlay includes clotilde install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-clotilde.sh.tmpl" ]
}

@test "ai-tooling: overlay includes ollama install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-ollama.sh" ]
}

@test "ai-tooling: ollama script is skipped in container via .chezmoiignore" {
  # .chezmoiignore is evaluated by chezmoi during apply, not during overlay
  # Check that .chezmoiignore contains the ollama script skip rule
  grep -q "install-ollama" "$DOTFILES/compiled-home/.chezmoiignore"
}

@test "ai-tooling: overlay includes .chezmoiignore" {
  [ -f "$DOTFILES/compiled-home/.chezmoiignore" ]
}