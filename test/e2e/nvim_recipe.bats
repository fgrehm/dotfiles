#!/usr/bin/env bats
# Tests for the nvim recipe: install script, symlink, plugin setup.
#
# Run: bats test/e2e/nvim_recipe.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "nvim"
  # The symlink target must exist in the test repo (mirrors real repo structure)
  mkdir -p "$DOTFILES/config/nvim"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "nvim: overlay includes all recipe files in compiled-home" {
  [ -f "$DOTFILES/compiled-home/private_dot_config/symlink_nvim.tmpl" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-neovim.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_after_setup-neovim.sh" ]
}

@test "nvim: chezmoi apply creates ~/.config/nvim symlink" {
  chezmoi_apply_files

  [ -L "$HOME/.config/nvim" ]
}

@test "nvim: symlink points to config/nvim in the repo working tree" {
  chezmoi_apply_files

  local target
  target="$(readlink "$HOME/.config/nvim")"
  [[ "$target" == *"/config/nvim" ]]
}

@test "nvim: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
