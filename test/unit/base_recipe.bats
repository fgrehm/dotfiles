#!/usr/bin/env bats
# Tests for the base recipe: foundational apt package install script.
#
# Run: bats test/unit/base_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "base"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "base: overlay includes install script in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_000-install-base-packages.sh.tmpl" ]
}

@test "base: install script sorts before other run_once_ scripts" {
  # 000- prefix must lexicographically precede all install-* scripts
  first=$(ls "$DOTFILES/compiled-home/.chezmoiscripts/run_once_"* 2>/dev/null | head -1 | xargs basename)
  [ "$first" = "run_once_000-install-base-packages.sh.tmpl" ]
}
