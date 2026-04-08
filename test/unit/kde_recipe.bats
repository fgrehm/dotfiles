#!/usr/bin/env bats
# Tests for the kde recipe: keyboard config and cedilla fix.
# Laptop-only recipe, skipped in containers via .recipeignore.
#
# Run: bats test/unit/kde_recipe.bats
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
  copy_recipe "kde"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "kde: overlay includes scripts and config in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_onchange_configure-keyboard.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_onchange_configure-cedilla.sh.tmpl" ]
  [ -f "$DOTFILES/compiled-home/private_dot_config/environment.d/cedilla.conf" ]
}

@test "kde: chezmoi apply deploys cedilla.conf" {
  chezmoi_apply_files

  [ -f "$HOME/.config/environment.d/cedilla.conf" ]
}

@test "kde: cedilla.conf sets GTK_IM_MODULE" {
  chezmoi_apply_files

  grep -q 'GTK_IM_MODULE=cedilla' "$HOME/.config/environment.d/cedilla.conf"
}

@test "kde: cedilla.conf sets QT_IM_MODULE" {
  chezmoi_apply_files

  grep -q 'QT_IM_MODULE=cedilla' "$HOME/.config/environment.d/cedilla.conf"
}

@test "kde: recipeignore excludes recipe when isContainer=true" {
  seed_chezmoi_config "true"
  rm -rf "$DOTFILES/compiled-home"
  run_overlay

  [ ! -f "$DOTFILES/compiled-home/private_dot_config/environment.d/cedilla.conf" ]
}

@test "kde: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts,externals --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
