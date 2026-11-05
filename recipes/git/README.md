# git

Git configuration, global gitignore, shell aliases, and TUI tooling.

## What it does

- Installs git via apt (Debian) / pacman (Omarchy) (graceful failure, idempotent)
- Uses Omarchy-managed Git utilities (`gh` and `lazygit`) without installing duplicate copies
- Installs Worktrunk (`wt`) and Hunk through Omarchy's mise wrapper
- Deploys `~/.config/git/config` (XDG location, templated for user identity)
- Deploys `~/.config/git/ignore` (global ignores for editor swap files, OS cruft, AI tooling)
- Deploys `~/.config/hunk/config.toml` (Hunk diff review TUI settings)
- Adds shell aliases and Bash/Zsh completions via `~/.shellrc.d/git.sh` and the Git utility completion script

## Config highlights

- Histogram diff algorithm, colorMoved, fetch prune
- Git LFS filter configured (install `git-lfs` separately before using LFS repositories)

On Omarchy, `gh` and `lazygit` are managed by Omarchy and are not duplicated here. Worktrunk and Hunk are installed through the shared mise recipe.

## Template variables

| Variable | Description | Source |
|----------|-------------|--------|
| `.name` | User's full name | `chezmoi init` prompt |
| `.email` | User's email address | `chezmoi init` prompt |
