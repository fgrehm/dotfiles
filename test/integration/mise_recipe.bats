#!/usr/bin/env bats
# Integration test: mise recipe installs mise and deploys shellrc fragment.
#
# Runs chezmoi apply including scripts.
# Run: make test-integration

load ../e2e/test_helper

setup() {
  skip_if_not_container
  skip_if_no_integration
  isolate_home
  setup_dotfiles_repo
  copy_recipe "mise"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "mise: install script makes mise available" {
  chezmoi_apply_full

  command -v mise
  mise --version
}

@test "mise: shellrc fragment is deployed" {
  chezmoi_apply_full

  [ -f "$HOME/.shellrc.d/mise.sh" ]
}

@test "mise: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
