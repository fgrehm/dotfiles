#!/usr/bin/env bats
# Tests for the cartage recipe in a container environment (isContainer=true).
#
# Run: bats test/e2e/cartage_recipe.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template  # sets isContainer=true
  copy_recipe "cartage"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "cartage: overlay includes all recipe files in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-cartage.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_onchange_after_enable-cartage.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/private_dot_config/systemd/user/cartage.service" ]
  [ -f "$DOTFILES/compiled-home/dot_local/bin/symlink_pbcopy" ]
  [ -f "$DOTFILES/compiled-home/dot_local/bin/symlink_notify-send" ]
}

@test "cartage: chezmoi apply creates container symlinks" {
  chezmoi_apply_files

  [ -L "$HOME/.local/bin/pbcopy" ]
  [ -L "$HOME/.local/bin/pbpaste" ]
  [ -L "$HOME/.local/bin/notify-send" ]
  [ -L "$HOME/.local/bin/yad" ]
  [ -L "$HOME/.local/bin/xdg-open" ]
}

@test "cartage: container symlinks point to cartage binary" {
  chezmoi_apply_files

  [ "$(readlink "$HOME/.local/bin/pbcopy")" = "cartage" ]
  [ "$(readlink "$HOME/.local/bin/pbpaste")" = "cartage" ]
  [ "$(readlink "$HOME/.local/bin/notify-send")" = "cartage" ]
  [ "$(readlink "$HOME/.local/bin/yad")" = "cartage" ]
  [ "$(readlink "$HOME/.local/bin/xdg-open")" = "cartage" ]
}

@test "cartage: systemd service file not deployed in container" {
  chezmoi_apply_files

  [ ! -f "$HOME/.config/systemd/user/cartage.service" ]
}

@test "cartage: diff is clean after apply in container" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
