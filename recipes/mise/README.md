# mise

[mise](https://mise.jdx.dev) dev tool version manager.

## What it does

- Installs mise to `~/.local/bin/mise` via the official install script
- Adds `dot_shellrc.d/mise.sh` to activate mise in bash and zsh shells
- Installs shared command-line tools through mise when they are missing: `shfmt`, `shellcheck`, Worktrunk (`wt`), Hunk (`hunk`), `gh`, and `prek`
- Uses `omarchy-mise-install` on Omarchy and direct `mise use -g` elsewhere
- Generates Bash/Zsh completions for `prek`; `gh` completions remain in the Git recipe
- Does not deploy `~/.config/mise/config.toml`; tools are added to the existing global mise configuration

## Requirements

- wget
- Internet access (mise.run install script)

## Notes

In devcontainers where mise is already installed (e.g. via the devcontainer feature), the
install script skips installation. The shell activation fragment still runs, so `mise` works
normally in the shell.

Containers manage their own mise tool versions; this recipe only installs mise when it is absent and enables shell activation.
