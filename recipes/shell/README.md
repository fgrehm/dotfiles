# shell

Core shell infrastructure: bash, zsh (via Oh My Zsh), and the modular
`~/.shellrc.d/` loader that other recipes use for shell fragments.

## What it does

- Deploys `~/.bashrc` (standard Debian defaults + shellrc loader)
- Deploys `~/.zshrc` (Oh My Zsh + git prompt extensions + shellrc loader)
- Deploys `~/.shellrc` (sources `~/.shellrc.d/*.sh` alphabetically, then `~/.shellrc.local`)
- Deploys `~/.shellrc.d/env.sh` (PATH, editor, history)
- Deploys `~/.shellrc.d/aliases.sh` (ls, grep color aliases)
- Creates `~/.shellrc.local` for machine-local overrides (not managed by chezmoi)
- Installs Oh My Zsh (unattended, preserves existing `.zshrc`)

## Requirements

- Debian 13 (Trixie)
- wget (for Oh My Zsh install, available by default on Debian)

## Template variables

| Variable | Description | Source |
|----------|-------------|--------|
| `.name` | User's full name | `chezmoi init` prompt |
| `.email` | User's email address | `chezmoi init` prompt |
| `.isContainer` | true in Docker/devcontainers | auto-detected |

## Adding shell fragments from other recipes

Other recipes can drop files into `dot_shellrc.d/` and they'll be sourced
automatically by the loader. Convention:

```
recipes/git/chezmoi/dot_shellrc.d/git.sh
recipes/podman/chezmoi/dot_shellrc.d/podman.sh
```

Guard with `command -v` so the fragment is safe before the tool is installed:

```bash
# shellcheck shell=bash
if ! command -v git &>/dev/null; then
  return 0
fi
alias g='git status'
```
