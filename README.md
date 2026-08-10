# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). Primary laptop target is [Omarchy](https://omarchy.org/) (Arch-based, Hyprland); Debian 13 (Trixie) is kept for devcontainers/Codespaces.

> **Debian is being dropped as a bare-metal/laptop target** — Omarchy replaces it on laptops. Debian remains supported for devcontainers/Codespaces. Recipes are adapted to Omarchy one at a time; Debian support is kept alongside until the transition is complete.

## Supported Platforms

- **Omarchy** (Arch-based, Hyprland) — primary laptop target
- **Debian-based containers** (Ubuntu, Debian, etc. for devcontainers/CI)
- **Debian 13** (laptop) — legacy, being dropped in favor of Omarchy

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

On a new **Debian** laptop, `chezmoi apply` needs to run twice:

1. **First apply** -- installs 1Password and the `op` CLI, then downloads SSH keys from your 1Password vault. Other recipes that need SSH (e.g. private repos) will skip gracefully on this run.
2. **Second apply** -- SSH keys are now on disk; any recipe that skipped will retry and complete normally.

On **Omarchy**, 1Password is preinstalled, so this two-pass dance is not needed.

## Development

Development and testing happens inside a devcontainer (Debian 13).

```bash
# Open devcontainer, then:
make test       # run e2e tests (bats)
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects containers via `/.dockerenv`, env vars, etc. Template data available: `.name`, `.email`, `.isContainer`, `.isDebian`, `.isOmarchy`, `.hasNvidiaGPU`, `.onepasswordSshVault`, `.onepasswordSshItem`.

## License

MIT
