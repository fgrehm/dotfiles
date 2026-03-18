#!/usr/bin/env bats
# Tests for the dot-ai recipe.
#
# Run: bats test/e2e/dot_ai_recipe.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "dot-ai"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "dot-ai: overlay includes both install scripts in compiled-home" {
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai.sh" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-dot-ai-private.sh" ]
}
