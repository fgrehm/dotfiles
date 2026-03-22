#!/usr/bin/env bats
# Integration test: laptop recipe installs vhs and ttyd.
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
  copy_recipe "laptop"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "laptop: install script makes ttyd available" {
  chezmoi_apply_full

  command -v ttyd
}

@test "laptop: install script makes vhs available" {
  chezmoi_apply_full

  command -v vhs
  vhs --version
}

@test "laptop: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
