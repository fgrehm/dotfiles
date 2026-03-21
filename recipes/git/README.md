# git

Git configuration, global gitignore, shell aliases, and TUI tooling.

## What it does

- Installs git via apt (graceful failure, idempotent)
- Installs [diffnav](https://github.com/dlvhdr/diffnav) — TUI diff pager (configured as default pager)
- Installs [worktrunk](https://worktrunk.dev) — git worktree manager (`wt` CLI)
- Deploys `~/.config/git/config` (XDG location, templated for user identity and SSH signing)
- Deploys `~/.config/git/ignore` (global ignores for editor swap files, OS cruft, AI tooling)
- Deploys `~/.config/diffnav/config.yml` (commented-out defaults)
- Deploys `~/.config/worktrunk/config.toml` (commented-out defaults)
- Adds shell aliases and zsh completions via `~/.shellrc.d/git.sh`

## Config highlights

- SSH commit signing (auto-detected: only enabled if `~/.ssh/id_ed25519-sign.pub` exists)
- SSH URLs for GitHub (`git@github.com:` instead of `https://`)
- Histogram diff algorithm, colorMoved, fetch prune
- Git LFS filter configured

## Requirements

- Debian 13 (Trixie)

## Template variables

| Variable | Description | Source |
|----------|-------------|--------|
| `.name` | User's full name | `chezmoi init` prompt |
| `.email` | User's email address | `chezmoi init` prompt |
