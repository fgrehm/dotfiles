# mise

[mise](https://mise.jdx.dev) dev tool version manager.

## What it does

- Installs mise to `~/.local/bin/mise` via the official install script
- Adds `dot_shellrc.d/mise.sh` to activate mise in bash and zsh shells
- Deploys `~/.config/mise/config.toml` with global tools (node, go, ruby, rust)
- Runs `mise install` after config deployment (re-runs when config changes)

## Requirements

- wget
- Internet access (mise.run install script, tool downloads)

## Notes

In devcontainers where mise is already installed (e.g. via the devcontainer feature), the
install script skips installation. The shell activation fragment still runs, so `mise` works
normally in the shell.

The global `config.toml` and `mise install` are skipped in containers (containers
manage their own tool versions).
