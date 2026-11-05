# shell

Core shell infrastructure for Omarchy Bash and non-Omarchy Bash/Zsh setups, plus the modular `~/.shellrc.d/` loader that other recipes use for shell fragments.

## What it does

- Deploys `~/.bashrc` (on Omarchy: omarchy's `default/bash/rc` + shellrc loader; on containers: standard Debian skeleton + shellrc loader)
- Deploys `~/.zshrc` on non-Omarchy hosts (Oh My Zsh + git prompt extensions + shellrc loader)
- Deploys `~/.shellrc` (sources `~/.shellrc.d/*.sh` alphabetically, then `~/.shellrc.local`)
- Deploys `~/.shellrc.d/env.sh` (PATH, editor, history)
- Deploys `~/.shellrc.d/aliases.sh` (ls, grep color aliases; `cdp`/`cdpo` project shortcuts with tab-completion of subdirectories, skipped in containers)
- Creates `~/.shellrc.local` for machine-local overrides (not managed by chezmoi)
- Installs Oh My Zsh on non-Omarchy hosts (unattended, preserves existing `.zshrc`)

## Provisioned guests

On a machine whose home is hydrated by a platform (`.hydratesHome`), the platform owns `~/.bashrc` and `~/.zshrc`: it writes managed blocks into them and refreshes them on every boot. Replacing those files wholesale drops the platform's setup, so on such a home chezmoi skips the two files and `run_onchange_after_merge-shell-rc.sh` maintains a marked block of our own inside them instead:

```
# bb-image managed >>>
eval "$(mise activate bash)"
# bb-image managed <<<

# dotfiles managed >>>
# Source shared shell configuration (env vars, aliases, PATH)
if [ -f "$HOME/.shellrc" ]; then
  . "$HOME/.shellrc"
fi
# dotfiles managed <<<
```

The block is refreshed in place, so re-running is a no-op and anything the user added outside the markers is preserved. The block content lives in `.chezmoitemplates/shellrc-block.sh` and is shared by the whole-file deploy and the merge, so the two cannot drift.

The shared block is deliberately the only thing dotfiles contributes to a guest's rc files. On non-Omarchy machines owned by dotfiles, the Debian skeleton and Oh My Zsh setup provide shell baselines; on a guest, the platform provides the baseline and the guest's shell is not the login shell anyway.

## Requirements

- Containers: Debian 13 (Trixie); `wget` (for Oh My Zsh install, available by default)
- Omarchy: Bash is selected as the default shell; Zsh and Oh My Zsh are not installed or configured by this recipe

## Omarchy

On Omarchy, the recipe selects Bash as the default shell, skips Zsh and Oh My Zsh, and manages `~/.bashrc` to source Omarchy's `default/bash/rc` followed by the shared shellrc loader. On existing hosts, it does not uninstall a Zsh package or delete an existing `~/.oh-my-zsh` directory or `.zshrc`; those files are simply no longer managed by this recipe.

## Template variables

| Variable | Description | Source |
|----------|-------------|--------|
| `.name` | User's full name | `chezmoi init` prompt |
| `.email` | User's email address | `chezmoi init` prompt |
| `.isContainer` | true in Docker containers | auto-detected |
| `.isOmarchy` | true on Omarchy hosts | auto-detected |

In containers, chezmoi never changes the account's login shell; that remains
owned by the image or container runtime. Shell configuration and missing tools
can still be installed without changing the login-shell contract.

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
