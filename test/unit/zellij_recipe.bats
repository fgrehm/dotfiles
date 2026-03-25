#!/usr/bin/env bats
# Tests for the zellij recipe.
#
# Run: bats test/e2e/zellij_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "zellij"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "zellij: overlay includes all recipe files in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-zellij.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/private_dot_config/zellij/config.kdl" ]
  [ -f "$DOTFILES/compiled-home/private_dot_config/zellij/layouts/zellaude.kdl" ]
}

@test "zellij: chezmoi apply deploys config.kdl" {
  chezmoi_apply_files

  [ -f "$HOME/.config/zellij/config.kdl" ]
}

@test "zellij: chezmoi apply deploys zellaude layout" {
  chezmoi_apply_files

  [ -f "$HOME/.config/zellij/layouts/zellaude.kdl" ]
}

@test "zellij: config uses locked mode by default" {
  chezmoi_apply_files

  grep -q 'default_mode "locked"' "$HOME/.config/zellij/config.kdl"
}

@test "zellij: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts,externals --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
