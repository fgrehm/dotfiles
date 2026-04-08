#!/usr/bin/env bats
# Integration test: terminal recipe installs alacritty and sets it as default.
#
# Uses isContainer=false config so .recipeignore does not skip the recipe,
# even though the test itself runs inside a container.
# Requires network access and DOTFILES_INTEGRATION=1.
# Run: make test-e2e

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
  skip_if_no_integration
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

@test "terminal: alacritty is available after apply" {
  chezmoi_apply_full

  command -v alacritty
}

@test "terminal: alacritty config is deployed" {
  chezmoi_apply_full

  [ -f "$HOME/.config/alacritty/alacritty.toml" ]
  grep -q 'CaskaydiaMono Nerd Font Mono' "$HOME/.config/alacritty/alacritty.toml"
}

@test "terminal: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
