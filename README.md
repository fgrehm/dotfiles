# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). Primary laptop target is [Omarchy](https://omarchy.org/) (Arch-based, Hyprland); Debian 13 (Trixie) is kept for devcontainers/Codespaces.

> **Debian is still a supported bare-metal target** — one laptop still runs Debian 13. The ultimate goal is to migrate fully to Omarchy and drop Debian as bare-metal, keeping it for devcontainers/Codespaces. Recipes are adapted to Omarchy one at a time; Debian support is kept alongside until the transition is complete.

## Supported Platforms

- **Omarchy** (Arch-based, Hyprland) — primary laptop target
- **Debian-based containers** (Ubuntu, Debian, etc. for devcontainers/CI)
- **Debian 13** (laptop) — still supported (one laptop); ultimate goal is to migrate to Omarchy

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

1. **First apply** -- downloads SSH keys from your 1Password vault (on Debian it also installs 1Password and the `op` CLI first). Other recipes that need SSH (e.g. private repos) will skip gracefully on this run.
2. **Second apply** -- SSH keys are now on disk; any recipe that skipped will retry and complete normally.

On **Omarchy**, 1Password is preinstalled, so the first apply only downloads the SSH keys (no 1Password install) — the two-pass flow still applies.

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
