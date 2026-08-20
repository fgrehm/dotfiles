# mise

[mise](https://mise.jdx.dev) dev tool version manager.

## What it does

- Installs mise to `~/.local/bin/mise` via the official install script
- Adds `dot_shellrc.d/mise.sh` to activate mise in bash and zsh shells
- Does not manage the global mise tool list or `~/.config/mise/config.toml`; Omarchy owns that configuration

## Requirements

- wget
- Internet access (mise.run install script)

## Notes

In devcontainers where mise is already installed (e.g. via the devcontainer feature), the
install script skips installation. The shell activation fragment still runs, so `mise` works
normally in the shell.

Containers manage their own mise tool versions; this recipe only installs mise when it is absent and enables shell activation.
