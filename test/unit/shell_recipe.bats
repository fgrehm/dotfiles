#!/usr/bin/env bats
# Tests for the shell recipe: loader, bashrc, zshrc, shellrc.d modules.
#
# Run: bats test/e2e/shell_recipe.bats
#   or: make test

load ../test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "shell"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "shell: overlay includes all recipe files in compiled-home" {
  [ -f "$DOTFILES/compiled-home/dot_bashrc" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.tmpl" ]
  [ -f "$DOTFILES/compiled-home/dot_zshrc.tmpl" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/env.sh" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/aliases.sh" ]
  [ -f "$DOTFILES/compiled-home/create_dot_shellrc.local" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-ohmyzsh.sh" ]
}

@test "shell: deploys bashrc, shellrc, and zshrc" {
  chezmoi_apply_files

  [ -f "$HOME/.bashrc" ]
  [ -f "$HOME/.shellrc" ]
  [ -f "$HOME/.zshrc" ]
}

@test "shell: deploys shellrc.d modules" {
  chezmoi_apply_files

  [ -d "$HOME/.shellrc.d" ]
  [ -f "$HOME/.shellrc.d/env.sh" ]
  [ -f "$HOME/.shellrc.d/aliases.sh" ]
}

@test "shell: creates shellrc.local for machine-local overrides" {
  chezmoi_apply_files

  [ -f "$HOME/.shellrc.local" ]

  # Should contain the comment header, not be empty
  run cat "$HOME/.shellrc.local"
  [[ "$output" == *"machine-specific"* ]]
}

@test "shell: shellrc loader sources shellrc.d and shellrc.local" {
  chezmoi_apply_files

  run cat "$HOME/.shellrc"
  [[ "$output" == *'shellrc.d/*.sh'* ]]
  [[ "$output" == *'.shellrc.local'* ]]
}

@test "shell: bashrc sources shellrc" {
  chezmoi_apply_files

  run cat "$HOME/.bashrc"
  [[ "$output" == *'. ~/.shellrc'* ]]
}

@test "shell: zshrc sources shellrc" {
  chezmoi_apply_files

  run cat "$HOME/.zshrc"
  [[ "$output" == *'. ~/.shellrc'* ]]
}

@test "shell: env.sh sets up PATH and history" {
  chezmoi_apply_files

  run cat "$HOME/.shellrc.d/env.sh"
  [[ "$output" == *'/.local/bin'* ]]
  [[ "$output" == *'HISTSIZE'* ]]
}

@test "shell: aliases.sh has color aliases" {
  chezmoi_apply_files

  run cat "$HOME/.shellrc.d/aliases.sh"
  [[ "$output" == *"ls --color=auto"* ]]
  [[ "$output" == *"grep --color=auto"* ]]
}

@test "shell: other recipes can add shellrc.d fragments" {
  add_recipe "custom-tool" "dot_shellrc.d/custom-tool.sh" "alias ct='custom-tool'"
  run_overlay
  chezmoi_apply_files

  [ -f "$HOME/.shellrc.d/custom-tool.sh" ]
  run cat "$HOME/.shellrc.d/custom-tool.sh"
  [[ "$output" == *"alias ct='custom-tool'"* ]]
}

@test "shell: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts,externals --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
