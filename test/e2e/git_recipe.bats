#!/usr/bin/env bats
# Integration test: git recipe installs git and deploys config.
#
# Runs chezmoi apply including scripts. Requires a container with sudo.
# Run: make test-e2e

load ../test_helper

setup() {
  skip_if_not_container
  skip_if_no_integration
  isolate_home
  setup_dotfiles_repo
  copy_recipe "git"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "git: install script installs git" {
  chezmoi_apply_full

  command -v git
  git --version
}

@test "git: install script makes diffnav available" {
  chezmoi_apply_full

  command -v diffnav
  diffnav --version
}

@test "git: install script makes wt (worktrunk) available" {
  chezmoi_apply_full

  command -v wt
  wt --version
}

@test "git: config and ignore are deployed" {
  chezmoi_apply_full

  [ -f "$HOME/.config/git/config" ]
  [ -f "$HOME/.config/git/ignore" ]
}

@test "git: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
