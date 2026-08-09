# nvim

Neovim installation and LazyVim plugin setup.

## What it does

- Installs Neovim from GitHub releases tarball to `/opt`, symlinks to `/usr/local/bin/nvim` (skips if nvim already installed, e.g. on Omarchy)
- Creates `~/.config/nvim` as a symlink to `config/nvim/` in the repo (edits to live config edit the repo copy directly)
- Installs LazyVim plugins headlessly after file deployment

## Config

The actual Neovim config lives at `config/nvim/` in the repo root, not inside this recipe. It is a LazyVim setup that includes Omarchy-specific goodies guarded by `vim.fn.executable("omarchy")`:

- `lua/plugins/omarchy-theme-hotreload.lua` — hot-reloads the colorscheme when the Omarchy theme changes
- `lua/plugins/all-themes.lua` — loads all theme plugins for hot-reloading
- `lua/plugins/theme.lua` — symlink to the current Omarchy theme's `neovim.lua`, created by `run_once_after_link-omarchy-theme.sh` (so it follows `omarchy theme set`)
- `lua/config/remote_clipboard.lua` — OSC 52 clipboard with Wayland support (loaded from `options.lua` on Omarchy)
- `plugin/after/transparency.lua` — transparent highlight groups

On non-Omarchy (Debian), `lua/plugins/colorscheme.lua` handles theming via tinted-nvim/alacritty instead.

## Requirements

- wget
- Internet access (GitHub releases + LazyVim plugins)

## Template variables

None.
