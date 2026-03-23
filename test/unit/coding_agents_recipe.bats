#!/usr/bin/env bats
# Tests for the coding-agents recipe.
#
# Run: bats test/unit/coding_agents_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "coding-agents"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "coding-agents: overlay includes claude-code install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-claude-code.sh" ]
}

@test "coding-agents: overlay includes pi-agent install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_after_install-pi-agent.sh" ]
}

@test "coding-agents: overlay includes dot-ai install scripts" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai.sh" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai-private.sh" ]
}

@test "coding-agents: overlay includes dotmem install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dotmem.sh.tmpl" ]
}

@test "coding-agents: overlay includes clotilde install script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-clotilde.sh.tmpl" ]
}
