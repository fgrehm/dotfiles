#!/usr/bin/env bats
# Tests for the clotilde recipe.
#
# Run: bats test/e2e/clotilde_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "clotilde"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "clotilde: overlay includes install script in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-clotilde.sh.tmpl" ]
}
