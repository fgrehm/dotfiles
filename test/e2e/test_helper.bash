# Shared helpers for dotfiles e2e tests.
# Sourced by bats tests via: load test_helper

# Skip the entire test if not running inside a container.
skip_if_not_container() {
  if [ ! -f "/.dockerenv" ] \
    && [ ! -f "/run/.containerenv" ] \
    && [ ! -f "/var/devcontainer" ] \
    && [ -z "${CODESPACES:-}" ] \
    && [ -z "${REMOTE_CONTAINERS:-}" ] \
    && [ -z "${container:-}" ] \
    && [ -z "${DOTFILES_E2E:-}" ]; then
    skip "not running inside a container (set DOTFILES_E2E=1 to force)"
  fi
}

# Absolute path to the real dotfiles-new repo root.
project_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

# Create a temporary dotfiles repo seeded from the real repo's home/ and recipes/.
# Sets DOTFILES to the created directory.
setup_dotfiles_repo() {
  DOTFILES="$(mktemp -d)"
  cd "$DOTFILES"
  git init -q -b main

  printf 'compiled-home\n' >.chezmoiroot
  printf 'compiled-home/\n' >.gitignore

  mkdir -p home recipes compiled-home

  # Copy the real config template so hooks and data match the project
  local real_root
  real_root="$(project_root)"
  cp "$real_root/home/.chezmoi.toml.tmpl" "$DOTFILES/home/.chezmoi.toml.tmpl"

  # Patch recipesDir to point at this temp repo's recipes/
  sed -i "s|recipesDir = .*|recipesDir = \"$DOTFILES/recipes\"|" "$DOTFILES/home/.chezmoi.toml.tmpl"
}

# Write a minimal .chezmoi.toml.tmpl with no hooks and no prompts.
# Includes all standard template variables so recipe templates render correctly.
write_minimal_config_template() {
  cat >"$DOTFILES/home/.chezmoi.toml.tmpl" <<'TMPL'
[data]
    name = "Test User"
    email = "test@example.com"
    isContainer = true
    isDebian = true
    hasNvidiaGPU = false
TMPL
}

# Copy a recipe from the real repo into the test repo.
# Usage: copy_recipe <name>
copy_recipe() {
  local name="$1"
  local real_root
  real_root="$(project_root)"
  cp -a "$real_root/recipes/$name" "$DOTFILES/recipes/$name"
}

# Run chezmoi apply, skipping script execution.
# Use this to test file deployment without triggering install scripts.
chezmoi_apply_files() {
  chezmoi apply --no-tty --exclude=scripts --source "$DOTFILES"
}

# Add a recipe with a single chezmoi source file.
# Usage: add_recipe <name> <relpath> <content>
add_recipe() {
  local name="$1" relpath="$2" content="$3"
  local dir="$DOTFILES/recipes/$name/chezmoi"
  mkdir -p "$dir/$(dirname "$relpath")"
  printf '%s\n' "$content" >"$dir/$relpath"
  printf '# %s\n' "$name" >"$DOTFILES/recipes/$name/README.md"
}

# Add a file to home/.
# Usage: add_home_file <relpath> <content>
add_home_file() {
  local relpath="$1" content="$2"
  mkdir -p "$DOTFILES/home/$(dirname "$relpath")"
  printf '%s\n' "$content" >"$DOTFILES/home/$relpath"
}

# Run chezmoi-recipes overlay against the temp repo.
run_overlay() {
  chezmoi-recipes overlay --recipes-dir "$DOTFILES/recipes"
}

# Run the overlay manually without chezmoi-recipes binary.
# Copies home/ then each recipe's chezmoi/ into compiled-home/.
run_manual_overlay() {
  rm -rf "$DOTFILES/compiled-home"
  mkdir -p "$DOTFILES/compiled-home"

  if [ -d "$DOTFILES/home" ] && [ "$(ls -A "$DOTFILES/home")" ]; then
    cp -a "$DOTFILES/home/." "$DOTFILES/compiled-home/"
  fi

  for recipe_dir in "$DOTFILES"/recipes/*/chezmoi; do
    [ -d "$recipe_dir" ] || continue
    cp -a "$recipe_dir/." "$DOTFILES/compiled-home/"
  done
}

# Override HOME and XDG dirs to isolate from the host.
isolate_home() {
  TEST_HOME="$(mktemp -d)"
  export HOME="$TEST_HOME"
  export XDG_CONFIG_HOME="$TEST_HOME/.config"
  export XDG_DATA_HOME="$TEST_HOME/.local/share"
  mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

  git config --global user.email "test@example.com"
  git config --global user.name "Test User"
}

# Run chezmoi init non-interactively with test identity values.
chezmoi_init() {
  local source_dir="${1:-$DOTFILES}"
  chezmoi init --no-tty --source "$source_dir" \
    --promptString name="Test User" \
    --promptString email="test@example.com"
}

# Run chezmoi apply including scripts (full integration apply).
# Requires a container environment; use chezmoi_apply_files for unit tests.
chezmoi_apply_full() {
  chezmoi apply -v --source "$DOTFILES"
}

# Skip if DOTFILES_INTEGRATION=1 is not set.
# Integration tests install real tools and require a container.
skip_if_no_integration() {
  if [ -z "${DOTFILES_INTEGRATION:-}" ]; then
    skip "integration test: set DOTFILES_INTEGRATION=1 to run (requires container)"
  fi
}

# Clean up temp dirs.
cleanup() {
  [ -n "${DOTFILES:-}" ] && rm -rf "$DOTFILES"
  [ -n "${TEST_HOME:-}" ] && rm -rf "$TEST_HOME"
}
