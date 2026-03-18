# zellij

[Zellij](https://zellij.dev) terminal multiplexer.

## What it does

- Installs zellij binary to `~/.local/bin/zellij` from GitHub releases
- Deploys `~/.config/zellij/config.kdl` (custom keybindings, Ctrl+A prefix, vibrant theme)
- Deploys `~/.config/zellij/layouts/zellaude.kdl` (zellaude Claude Code status bar layout)

## Requirements

- Debian 13 (Trixie)
- wget
- Internet access (GitHub releases)

## Notes

The zellaude layout loads the [zellaude](https://github.com/ishefi/zellaude) wasm plugin
from GitHub releases at startup — no separate plugin install needed. The `zellaude-hook.sh`
bridge script is placed under `~/.config/zellij/plugins/` by the plugin automatically on
first load.
