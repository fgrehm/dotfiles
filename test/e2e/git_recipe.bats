#!/usr/bin/env bats
# Tests for the git recipe: config, gitignore, shell aliases.
#
# Run: bats test/e2e/git_recipe.bats
#   or: make test

load test_helper

setup() {
  skip_if_not_container
  isolate_home
  setup_dotfiles_repo
  write_minimal_config_template
  copy_recipe "git"
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
}

teardown() {
  cleanup
}

@test "git: overlay includes all recipe files in compiled-home" {
  [ -f "$DOTFILES/compiled-home/private_dot_config/git/config.tmpl" ]
  [ -f "$DOTFILES/compiled-home/dot_gitignore" ]
  [ -f "$DOTFILES/compiled-home/dot_shellrc.d/git.sh" ]
  [ -f "$DOTFILES/compiled-home/.chezmoiscripts/run_once_install-git.sh.tmpl" ]
}

@test "git: deploys git config to XDG location" {
  chezmoi_apply_files

  [ -f "$HOME/.config/git/config" ]
}

@test "git: config contains user identity from template data" {
  chezmoi_apply_files

  run cat "$HOME/.config/git/config"
  [[ "$output" == *"Test User"* ]]
  [[ "$output" == *"test@example.com"* ]]
}

@test "git: config has sensible defaults" {
  chezmoi_apply_files

  run cat "$HOME/.config/git/config"
  [[ "$output" == *"defaultBranch = main"* ]]
  [[ "$output" == *"algorithm = histogram"* ]]
  [[ "$output" == *"prune = true"* ]]
}

@test "git: deploys global gitignore" {
  chezmoi_apply_files

  [ -f "$HOME/.gitignore" ]

  run cat "$HOME/.gitignore"
  [[ "$output" == *".DS_Store"* ]]
  [[ "$output" == *".swp"* ]]
}

@test "git: deploys shell aliases" {
  chezmoi_apply_files

  [ -f "$HOME/.shellrc.d/git.sh" ]

  run cat "$HOME/.shellrc.d/git.sh"
  [[ "$output" == *"alias gs='git status'"* ]]
  [[ "$output" == *"alias gd='git diff'"* ]]
}

@test "git: shell aliases have command guard" {
  chezmoi_apply_files

  run cat "$HOME/.shellrc.d/git.sh"
  [[ "$output" == *"command -v git"* ]]
}

@test "git: config skips user section when placeholders" {
  # Override with placeholder values
  cat >"$DOTFILES/home/.chezmoi.toml.tmpl" <<'TMPL'
[data]
    name = "TODO: Your Name"
    email = "TODO@example.com"
    isContainer = true
    isDebian = true
    hasNvidiaGPU = false
TMPL
  run_overlay
  chezmoi init --no-tty --source "$DOTFILES"
  chezmoi_apply_files

  run cat "$HOME/.config/git/config"
  [[ "$output" != *"[user]"* ]]
}

@test "git: diff is clean after apply" {
  chezmoi_apply_files

  run chezmoi diff --no-tty --exclude=scripts --source "$DOTFILES"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
