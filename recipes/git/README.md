# git

Git configuration, global gitignore, and shell aliases.

## What it does

- Deploys `~/.config/git/config` (XDG location, templated for user identity and SSH signing)
- Deploys `~/.config/git/ignore` (global ignores for editor swap files, OS cruft, AI tooling)
- Adds shell aliases and zsh completions via `~/.shellrc.d/git.sh`

## Config highlights

- SSH commit signing (auto-detected: only enabled if `~/.ssh/id_ed25519-sign.pub` exists)
- SSH URLs for GitHub (`git@github.com:` instead of `https://`)
- Histogram diff algorithm, colorMoved, fetch prune
- diffnav as default pager for `diff` and `show` (requires diffnav to be installed)
- Git LFS filter configured

## Requirements

- Debian 13 (Trixie)
- git (installed via apt, not managed by this recipe)

## Template variables

| Variable | Description | Source |
|----------|-------------|--------|
| `.name` | User's full name | `chezmoi init` prompt |
| `.email` | User's email address | `chezmoi init` prompt |
