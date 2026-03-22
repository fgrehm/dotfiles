#!/usr/bin/env bats
# Tests for the laptop recipe: overlay includes scripts on laptop, and
# .recipeignore excludes the recipe in containers.
#
# Run: bats test/unit/laptop_recipe.bats
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
  copy_recipe "laptop"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "laptop: overlay includes install scripts in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-vhs.sh" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-ttyd.sh" ]
}

@test "laptop: recipeignore excludes recipe when isContainer=true" {
  seed_chezmoi_config "true"
  rm -rf "$DOTFILES/compiled-home"
  run_overlay

  [ ! -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-vhs.sh" ]
  [ ! -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-ttyd.sh" ]
}
