# mise

[mise](https://mise.jdx.dev) dev tool version manager.

## What it does

- Installs mise to `~/.local/bin/mise` from a pinned GitHub release with a SHA-256 check
- Adds `dot_shellrc.d/mise.sh` to activate mise in bash and zsh shells
- Installs shared command-line tools through mise when they are missing: `shfmt`, `shellcheck`, Worktrunk (`wt`), Hunk (`hunk`), `gh`, `prek`, and `bat`
- Uses `omarchy-mise-install` on Omarchy and direct `mise use -g` elsewhere
- Generates Bash/Zsh completions for `prek`; `gh` completions remain in the Git recipe
- Does not deploy `~/.config/mise/config.toml`; tools are added to the existing global mise configuration

## Requirements

- wget
- Internet access to download the pinned GitHub release

## Notes

In devcontainers and VMs where mise is already installed, the install script skips installation. The shell activation fragment still runs, so `mise` works normally in the shell.

Container and VM environments can manage their own mise tool versions; this recipe only installs mise when it is absent and enables shell activation.

## Provisioned guests

On a machine whose toolchain is provided by a platform (`.hasToolchain`), the global mise configuration belongs to the platform: it is baked into the image and `MISE_GLOBAL_CONFIG_FILE` points at a path outside `$HOME`. Writing to it with `mise use -g` would rewrite the platform's deliberate version pins and the change would be lost when the container is replaced, so the tool install script installs nothing there and reports which tools the platform does not provide. A tool a guest needs belongs in the platform image.
