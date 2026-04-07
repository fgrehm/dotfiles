# terminal

Terminal emulator setup.

## What it does

- Installs [alacritty](https://alacritty.org/) via apt
- Deploys `~/.config/alacritty/alacritty.toml`
- Sets alacritty as default terminal via `update-alternatives`

## Config highlights

- CaskaydiaMono Nerd Font Mono
- Shift+Return sends literal newline (useful in zellij/tmux)
- Ctrl+Shift+N opens a new window
- Mouse cursor always visible (workaround for alacritty#6703)

## Requirements

- Debian 13 (Trixie)
- Skipped in containers via `.recipeignore`
