#!/usr/bin/env bats
# Tests for the mise recipe.
#
# Run: bats test/e2e/mise_recipe.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "shell"
  copy_recipe "mise"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "mise: overlay includes install script and shellrc fragment" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-mise.sh" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/mise.sh" ]
}

@test "mise: deploys shellrc.d fragment" {
  chezmoi_apply_files

  [ -f "$HOME/.shellrc.d/mise.sh" ]
}

@test "mise: shellrc fragment activates mise when available" {
  chezmoi_apply_files

  grep -q "mise activate" "$HOME/.shellrc.d/mise.sh"
}
