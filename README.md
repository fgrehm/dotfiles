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
sh -c "$(wget -qO- https://raw.githubusercontent.com/fgrehm/dotfiles/main/install.sh)"
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

See [`recipes/`](recipes/) for the full list. Each recipe has its own README.

## Fresh Machine Setup

On a new laptop, `chezmoi apply` needs to run twice:

1. **First apply** -- installs 1Password and the `op` CLI, then downloads SSH keys
   from your 1Password vault. Other recipes that need SSH (e.g. private repos) will
   skip gracefully on this run.
2. **Second apply** -- SSH keys are now on disk; any recipe that skipped will retry
   and complete normally.

## Development

Development and testing happens inside a devcontainer (Debian 13).

```bash
# Open devcontainer, then:
make test       # run e2e tests (bats)
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects containers via `/.dockerenv`, env vars, etc.
Template data available: `.name`, `.email`, `.isContainer`, `.isDebian`,
`.hasNvidiaGPU`, `.onepasswordSshVault`, `.onepasswordSshItem`.

## License

MIT
