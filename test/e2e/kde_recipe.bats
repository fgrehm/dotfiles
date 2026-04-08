#!/usr/bin/env bats
# Integration test: kde recipe scripts and config deployment.
#
# Uses isContainer=false config so .recipeignore does not skip the recipe,
# even though the test itself runs inside a container.
# Keyboard and cedilla scripts will skip (no KDE in container) but must not fail.
# Requires DOTFILES_INTEGRATION=1.
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
  copy_recipe "kde"
  cd "$DOTFILES"
  seed_chezmoi_config "false"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "kde: apply succeeds (scripts skip gracefully without KDE)" {
  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}

@test "kde: cedilla.conf is deployed after apply" {
  chezmoi_apply_full

  [ -f "$HOME/.config/environment.d/cedilla.conf" ]
  grep -q 'GTK_IM_MODULE=cedilla' "$HOME/.config/environment.d/cedilla.conf"
}

@test "kde: apply is idempotent" {
  chezmoi_apply_full

  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
