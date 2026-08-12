# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). Bare-metal/laptop target is [Omarchy](https://omarchy.org/) (Arch-based, Hyprland); Debian-based images are used for devcontainers/Codespaces.

## Supported Platforms

- **Omarchy** (Arch-based, Hyprland) — the bare-metal/laptop target
- **Debian-based containers** (Debian 13, Ubuntu, etc.) — devcontainers/Codespaces/CI

Omarchy is the only bare-metal target. The `apt` branches in install scripts exist for the container path; on Omarchy the equivalent steps go through `omarchy pkg add` / `pacman`.

## Quick Start

```bash
sh -c "$(wget -qO- https://raw.githubusercontent.com/fgrehm/dotfiles/main/install.sh)"
```

## How It Works

Dotfiles are organized into modular **recipes** under `recipes/`. Each recipe groups related chezmoi files (configs, install scripts, shell fragments) for a single tool. chezmoi-recipes overlays them into a generated `compiled-home/` directory, then chezmoi applies as normal.

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

See [`recipes/`](recipes/) for the full list. Each recipe has its own README.

## Fresh Machine Setup

On a new laptop, `chezmoi apply` needs to run twice:

1. **First apply** -- downloads SSH keys from your 1Password vault (on Omarchy, 1Password is preinstalled so only the key download runs). Other recipes that need SSH (e.g. private repos) will skip gracefully on this run.
2. **Second apply** -- SSH keys are now on disk; any recipe that skipped will retry and complete normally.

## Development

Development and testing happens inside a devcontainer (Debian 13).

```bash
# Open devcontainer, then:
make test       # run e2e tests (bats)
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects the environment via `/.dockerenv`, env vars, `omarchy` on PATH, etc. Template data available: `.name`, `.email`, `.isContainer`, `.isOmarchy`, `.useZsh`, `.hasNvidiaGPU`, `.onepasswordSshVault`, `.onepasswordSshItem`.

## License

MIT