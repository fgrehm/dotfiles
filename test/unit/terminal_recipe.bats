#!/usr/bin/env bats
# Tests for the terminal recipe: alacritty config deployment.
# Laptop-only recipe, skipped in containers via .recipeignore.
#
# Run: bats test/unit/terminal_recipe.bats
#   or: make test

load ../test_helper

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
  copy_recipeignore
  copy_recipe "terminal"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "terminal: overlay includes config and scripts in compiled-home" {
  [ -f "$DOTFILES/compiled-home/private_dot_config/alacritty/alacritty.toml" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-alacritty.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_onchange_after_set-alacritty-default.sh.tmpl" ]
}

@test "terminal: chezmoi apply deploys alacritty config" {
  chezmoi_apply_files

  [ -f "$HOME/.config/alacritty/alacritty.toml" ]
}

@test "terminal: config has expected font family" {
  chezmoi_apply_files

  grep -q 'CaskaydiaMono Nerd Font Mono' "$HOME/.config/alacritty/alacritty.toml"
}

@test "terminal: recipeignore excludes recipe when isContainer=true" {
  seed_chezmoi_config "true"
  rm -rf "$DOTFILES/compiled-home"
  run_overlay

  [ ! -f "$DOTFILES/compiled-home/private_dot_config/alacritty/alacritty.toml" ]
}

@test "terminal: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts,externals --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
