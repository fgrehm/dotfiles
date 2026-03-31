#!/usr/bin/env bats
# Integration test: 1password recipe installs 1Password desktop app and CLI.
#
# Uses isContainer=false so .recipeignore does not skip the recipe.
# Does not test SSH key download (requires live 1Password credentials).
# Requires network access and DOTFILES_INTEGRATION=1.
# Run: make test-e2e

load ../test_helper

write_1password_config_template() {
  cat >"$DOTFILES/home/.chezmoi.toml.tmpl" <<'TMPL'
[data]
    name = "Test User"
    email = "test@example.com"
    onepasswordSshVault = ""
    onepasswordSshItem = ""
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
  write_1password_config_template
  copy_recipeignore
  copy_recipe "1password"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "1password: install script makes op available" {
  chezmoi_apply_full

  command -v op
  op --version
}

@test "1password: 1password desktop package is installed" {
  chezmoi_apply_full

  dpkg -s 1password
}

@test "1password: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
