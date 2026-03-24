#!/usr/bin/env bats
# Integration test: all container-compatible recipes applied together.
#
# Applies once via setup_file, then each test asserts a specific outcome.
# Catches cross-recipe conflicts that per-recipe tests miss because they run in
# isolation. Laptop recipe is excluded by .recipeignore (isContainer=true).
#
# Run: make test-e2e

load ../test_helper

setup_file() {
  skip_if_not_container
  skip_if_no_integration
  isolate_home
  setup_dotfiles_repo
  copy_recipe "shell"
  copy_recipe "git"
  copy_recipe "mise"
  copy_recipe "nvim"
  copy_recipe "zellij"
  copy_recipe "cartage"
  copy_recipe "coding-agents"
  copy_recipe "laptop"
  copy_recipeignore
  seed_chezmoi_config
  cd "$DOTFILES"
  run_overlay
  chezmoi_init
  chezmoi_apply_full
}

teardown_file() {
  cleanup
}

# git

@test "git: git is available" {
  command -v git
  git --version
}

@test "git: diffnav is available" {
  command -v diffnav
  diffnav --version
}

@test "git: wt (worktrunk) is available" {
  command -v wt
  wt --version
}

@test "git: config and ignore are deployed" {
  [ -f "$HOME/.config/git/config" ]
  [ -f "$HOME/.config/git/ignore" ]
}

# mise

@test "mise: mise is available" {
  command -v mise
  mise --version
}

@test "mise: shellrc fragment is deployed" {
  [ -f "$HOME/.shellrc.d/mise.sh" ]
}

@test "mise: config.toml is skipped in container" {
  [ ! -f "$HOME/.config/mise/config.toml" ]
}

# zellij

@test "zellij: zellij is available" {
  command -v zellij
  zellij --version
}

# coding-agents

@test "coding-agents: claude is available" {
  command -v claude
}

@test "coding-agents: clotilde is available" {
  command -v clotilde
  clotilde --version
}

@test "coding-agents: dotmem is available" {
  command -v dotmem
  dotmem --version
}

@test "coding-agents: dot-ai is cloned" {
  [ -d "$HOME/.local/share/dot-ai" ]
}

# idempotency

@test "all recipes: second apply is a no-op" {
  run chezmoi_apply_full
  [ "$status" -eq 0 ]
}
