#!/usr/bin/env bats
# Integration test: zellij recipe downloads and installs zellij.
#
# Requires network access and a container.
# Run: make test-integration

load ../e2e/test_helper

setup() {
  skip_if_not_container
  skip_if_no_integration
  isolate_home
  setup_dotfiles_repo
  copy_recipe "shell"
  copy_recipe "zellij"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "zellij: install script makes zellij available" {
  chezmoi_apply_full

  command -v zellij
  zellij --version
}

@test "zellij: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
