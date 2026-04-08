# terminal

Terminal emulator setup.

## What it does

- Installs [alacritty](https://alacritty.org/) via apt
- Installs [CascadiaMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) (pinned, checksum verified)
- Deploys `~/.config/alacritty/alacritty.toml`
- Deploys `~/.config/fontconfig/conf.d/01-emoji.conf` (Noto Color Emoji fallback)
- Sets alacritty as default terminal via `update-alternatives`

## Config highlights

- CaskaydiaMono Nerd Font Mono
- Shift+Return sends literal newline (useful in zellij/tmux)
- Ctrl+Shift+N opens a new window
- Mouse cursor always visible (workaround for alacritty#6703)

## Requirements

- Debian 13 (Trixie)
- Depends on `base` recipe for `unzip` and `wget`; `fc-cache` is from
  `fontconfig` which is pre-installed on Debian desktop
- Skipped in containers via `.recipeignore`
