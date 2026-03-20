#!/usr/bin/env bats
# Basic chezmoi + chezmoi-recipes integration tests.
# Validates overlay mechanics with synthetic fixtures (no real recipes).
#
# Run: bats test/e2e/basics.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
}

teardown() {
  cleanup
}

@test "overlay merges home/ and recipe files into compiled-home" {
  add_home_file "dot_bashrc" "# from home"
  add_recipe "tool-a" "dot_tool_a" "config-a"

  cd "$DOTFILES"
  run_overlay

  [ -f "$DOTFILES/compiled-home/dot_bashrc" ]
  [ -f "$DOTFILES/compiled-home/dot_tool_a" ]

  run cat "$DOTFILES/compiled-home/dot_bashrc"
  [[ "$output" == *"from home"* ]]
}

@test "multiple recipes coexist in compiled-home" {
  add_recipe "tool-a" "dot_shellrc.d/tool-a.sh" "alias a='tool-a'"
  add_recipe "tool-b" "dot_shellrc.d/tool-b.sh" "alias b='tool-b'"

  cd "$DOTFILES"
  run_overlay

  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/tool-a.sh" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/tool-b.sh" ]
}

@test "chezmoi apply deploys files from home and recipes" {
  add_home_file "dot_bashrc" "# managed bashrc"
  add_recipe "tool-a" "dot_tool_a" "hello"

  cd "$DOTFILES"
  run_overlay
  chezmoi_init

  run chezmoi apply --no-tty --source "$DOTFILES"
  [ "$status" -eq 0 ]

  [ -f "$HOME/.bashrc" ]
  [ -f "$HOME/.tool_a" ]
}

@test "chezmoi diff is clean after apply" {
  add_home_file "dot_bashrc" "# bashrc"
  add_recipe "tool-a" "dot_tool_a" "config"

  cd "$DOTFILES"
  run_overlay
  chezmoi_init
  chezmoi apply --no-tty --source "$DOTFILES"

  run chezmoi diff --no-tty --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
