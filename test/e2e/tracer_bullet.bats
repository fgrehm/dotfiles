#!/usr/bin/env bats
# Tracer bullet: validate the chezmoi + chezmoi-recipes setup works end to end.
#
# Run: bats test/e2e/tracer_bullet.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
}

teardown() {
  cleanup
}

@test "chezmoi-recipes overlay compiles home and recipes into compiled-home" {
  add_home_file "dot_bashrc" "# bashrc from home"
  add_recipe "hello" "dot_hello" "hello from recipe"

  cd "$DOTFILES"
  run_overlay

  [ -f "$DOTFILES/compiled-home/dot_bashrc" ]
  [ -f "$DOTFILES/compiled-home/dot_hello" ]

  run cat "$DOTFILES/compiled-home/dot_bashrc"
  [[ "$output" == *"bashrc from home"* ]]

  run cat "$DOTFILES/compiled-home/dot_hello"
  [[ "$output" == *"hello from recipe"* ]]
}

@test "chezmoi apply deploys files from a recipe" {
  write_minimal_config_template
  add_home_file "dot_bashrc" "# managed bashrc"
  add_recipe "hello" "dot_hello" "hello world"

  cd "$DOTFILES"
  run_overlay
  chezmoi_init

  run chezmoi apply --no-tty --source "$DOTFILES"
  [ "$status" -eq 0 ]

  [ -f "$HOME/.bashrc" ]
  [ -f "$HOME/.hello" ]

  run cat "$HOME/.hello"
  [[ "$output" == *"hello world"* ]]
}

@test "chezmoi diff is clean after apply" {
  write_minimal_config_template
  add_home_file "dot_bashrc" "# bashrc"
  add_recipe "hello" "dot_hello" "hello"

  cd "$DOTFILES"
  run_overlay
  chezmoi_init
  chezmoi apply --no-tty --source "$DOTFILES"

  run chezmoi diff --no-tty --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
