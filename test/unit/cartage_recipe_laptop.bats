#!/usr/bin/env bats
# Tests for the cartage recipe in a laptop environment (isContainer=false).
#
# Run: bats test/e2e/cartage_recipe_laptop.bats
#   or: make test

load ../test_helper

# Write a minimal config template for a non-container (laptop) environment.
write_laptop_config_template() {
  cat >"$DOTFILES/home/.chezmoi.toml.tmpl" <<'TMPL'
[data]
    name = "Test User"
    email = "test@example.com"
    isContainer = false
    isDebian = true
    hasNvidiaGPU = false
TMPL
}

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_laptop_config_template
  copy_recipe "cartage"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "cartage (laptop): chezmoi apply creates systemd service file" {
  chezmoi_apply_files

  [ -f "$HOME/.config/systemd/user/cartage.service" ]
}

@test "cartage (laptop): service file has correct ExecStart" {
  chezmoi_apply_files

  grep -q "ExecStart=%h/.local/bin/cartage serve" "$HOME/.config/systemd/user/cartage.service"
}

@test "cartage (laptop): container symlinks not deployed on laptop" {
  chezmoi_apply_files

  [ ! -L "$HOME/.local/bin/pbcopy" ]
  [ ! -L "$HOME/.local/bin/pbpaste" ]
  [ ! -L "$HOME/.local/bin/notify-send" ]
  [ ! -L "$HOME/.local/bin/yad" ]
  [ ! -L "$HOME/.local/bin/xdg-open" ]
}

@test "cartage (laptop): diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
