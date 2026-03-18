# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and
[chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes), built for Debian
13 (Trixie). Also works in devcontainers/Codespaces.

> **Status:** early development, migrating from a previous setup.

## Supported Platforms

- **Debian 13** (laptop)
- **Debian-based containers** (Ubuntu, Debian, etc. for devcontainers/CI)

## Quick Start

```bash
# Install chezmoi and chezmoi-recipes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/fgrehm/chezmoi-recipes/main/install.sh)" -- <GITHUB_USERNAME>
```

**Already have both tools:**

```bash
chezmoi init <GITHUB_USERNAME>
chezmoi diff    # preview
chezmoi apply   # apply
```

## How It Works

Dotfiles are organized into modular **recipes** under `recipes/`. Each recipe
groups related chezmoi files (configs, install scripts, shell fragments) for a
single tool. chezmoi-recipes overlays them into a generated `compiled-home/`
directory, then chezmoi applies as normal.

```
home/                         shared chezmoi source files
recipes/
  <recipe-name>/
    README.md                 recipe documentation
    chezmoi/                  chezmoi source fragment for this recipe
      .chezmoiscripts/
      dot_*/
      private_dot_config/
compiled-home/                generated (gitignored), fed to chezmoi
```

## Recipes

| Recipe | What it manages |
|--------|----------------|
| **shell** | bash, zsh (Oh My Zsh), modular `~/.shellrc.d/` loader for other recipes |
| **git** | XDG git config (user identity, SSH signing), global gitignore, aliases + zsh completions |
| podman | (coming soon) |
| cartage | (coming soon) |

## Development

Development and testing happens inside a devcontainer (Debian 13).
[chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes) binary is mounted
from the host.

```bash
# Open devcontainer, then:
make test       # run e2e tests (bats)
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects containers via `/.dockerenv`, env vars, etc.
Template data available: `.name`, `.email`, `.isContainer`, `.isDebian`,
`.hasNvidiaGPU`.

## License

MIT
