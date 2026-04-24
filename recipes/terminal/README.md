# terminal

Terminal emulator setup.

## What it does

- Installs [alacritty](https://alacritty.org/) via apt
- Installs [CascadiaMono Nerd Font](https://github.com/ryanoasis/nerd-fonts) (pinned, checksum verified)
- Installs [tinty](https://github.com/tinted-theming/tinty) (base16 theme manager, pinned binary release)
- Deploys `~/.config/alacritty/alacritty.toml`
- Deploys `~/.config/fontconfig/conf.d/01-emoji.conf` (Noto Color Emoji fallback)
- Deploys `~/.config/tinted-theming/tinty/config.toml`
- Sets alacritty as default terminal via `update-alternatives`
- Seeds the initial alacritty color scheme (`base16-gruvbox-dark-hard`)

## Config highlights

- CaskaydiaMono Nerd Font Mono
- Shift+Return sends literal newline (useful in zellij/tmux)
- Ctrl+Shift+N opens a new window
- Mouse cursor always visible (workaround for alacritty#6703)
- Colors come from `~/.config/alacritty/colors.toml` (written by tinty,
  not managed by chezmoi)

## Theming

Tinty is the source of truth for base16 theme state. Run `tinty apply
<scheme>` to change the scheme across any integrated app. Per-app hooks
are configured in `~/.config/tinted-theming/tinty/config.toml`. Currently
wired apps: alacritty. See
[tinted-theming/schemes](https://github.com/tinted-theming/schemes) for
the full list of available schemes.

## Requirements

- Debian 13 (Trixie)
- Depends on `base` recipe for `unzip` and `wget`; `fc-cache` is from
  `fontconfig` which is pre-installed on Debian desktop
- Skipped in containers via `.recipeignore`
