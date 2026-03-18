# mise

[mise](https://mise.jdx.dev) dev tool version manager.

## What it does

- Installs mise to `~/.local/bin/mise` via the official install script
- Adds `dot_shellrc.d/mise.sh` to activate mise in bash and zsh shells

## Requirements

- wget
- Internet access (mise.run install script)

## Notes

In devcontainers where mise is already installed (e.g. via the devcontainer feature), the
install script skips installation. The shell activation fragment still runs, so `mise` works
normally in the shell.
