#!/usr/bin/env bats
# Integration test: coding-agents recipe installs agent tools.
#
# Runs chezmoi apply including scripts. Requires a container with network.
# Run: make test-e2e

load ../test_helper

setup() {
  skip_if_not_container
  skip_if_no_integration
  isolate_home
  setup_dotfiles_repo
  copy_recipe "coding-agents"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "coding-agents: install script makes claude available" {
  chezmoi_apply_full

  command -v claude
}

@test "coding-agents: install script makes clotilde available" {
  chezmoi_apply_full

  command -v clotilde
  clotilde --version
}

@test "coding-agents: install script makes dotmem available" {
  chezmoi_apply_full

  command -v dotmem
  dotmem --version
}

@test "coding-agents: dot-ai is cloned" {
  chezmoi_apply_full

  [ -d "$HOME/.local/share/dot-ai" ]
}

@test "coding-agents: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
