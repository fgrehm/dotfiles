# nvim

Neovim installation and LazyVim plugin setup.

## What it does

- Installs Neovim from GitHub releases tarball to `/opt`, symlinks to `/usr/local/bin/nvim`
- Creates `~/.config/nvim` as a symlink to `config/nvim/` in the repo (edits to live config
  edit the repo copy directly)
- Installs LazyVim plugins headlessly after file deployment

## Config

The actual Neovim config lives at `config/nvim/` in the repo root, not inside
this recipe. Populate it with your LazyVim setup before running `chezmoi apply`.

## Requirements

- Debian 13 (Trixie)
- wget
- Internet access (GitHub releases + LazyVim plugins)

## Template variables

None.
