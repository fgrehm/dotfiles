# shell

Core shell infrastructure: bash, zsh (via Oh My Zsh), and the modular
`~/.shellrc.d/` loader that other recipes use for shell fragments.

## What it does

- Deploys `~/.bashrc` (on Omarchy: omarchy's `default/bash/rc` + shellrc loader; on containers: standard Debian skeleton + shellrc loader)
- Deploys `~/.zshrc` (Oh My Zsh + git prompt extensions + shellrc loader)
- Deploys `~/.shellrc` (sources `~/.shellrc.d/*.sh` alphabetically, then `~/.shellrc.local`)
- Deploys `~/.shellrc.d/env.sh` (PATH, editor, history)
- Deploys `~/.shellrc.d/aliases.sh` (ls, grep color aliases; `cdp`/`cdpo` project shortcuts with tab-completion of subdirectories, skipped in containers)
- Creates `~/.shellrc.local` for machine-local overrides (not managed by chezmoi)
- Installs Oh My Zsh (unattended, preserves existing `.zshrc`)

## Requirements

- Containers: Debian 13 (Trixie); `wget` (for Oh My Zsh install, available by default)
- Omarchy: zsh is installed and selected as the default shell

## Omarchy

On Omarchy, zsh and Oh My Zsh are installed through `omarchy pkg add` and the default shell is switched to zsh. Bash remains supported: `~/.bashrc` sources Omarchy's `default/bash/rc` followed by the shared shellrc loader.

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

## Bash git-alias completion

Git aliases defined in `dot_shellrc.d/git.sh` need explicit completion wiring on bash (zsh gets it via `compdef`). Use git's `__git_complete <alias> _git_<subcommand>` (NOT `complete -F _git_<subcommand>`, which breaks because the completion functions expect `$1=git`). Source the git completion file first (it's lazy-loaded), then wire each alias. See `dot_shellrc.d/git.sh` for the working pattern.
