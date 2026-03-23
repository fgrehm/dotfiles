#!/usr/bin/env bats
# Tests for the mise recipe.
#
# Run: bats test/e2e/mise_recipe.bats
#   or: make test

load ../test_helper

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

@test "mise: overlay includes mise-tools onchange script" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_onchange_after_install-mise-tools.sh.tmpl" ]
}

@test "mise: deploys shellrc.d fragment" {
  chezmoi_apply_files

  [ -f "$HOME/.shellrc.d/mise.sh" ]
}

@test "mise: shellrc fragment sets up mise shims on PATH" {
  chezmoi_apply_files

  grep -q "mise shims-dir\|MISE_SHIMS_DIR" "$HOME/.shellrc.d/mise.sh"
}

@test "mise: skips config.toml in container" {
  chezmoi_apply_files

  [ ! -f "$HOME/.config/mise/config.toml" ]
}
