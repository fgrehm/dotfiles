# zellij

[Zellij](https://zellij.dev) terminal multiplexer.

## What it does

- Installs Zellij through mise (`omarchy-mise-install` on Omarchy)
- Deploys `~/.config/zellij/config.kdl` with custom keybindings and Omarchy theme integration
- Adds the `zac` shell helper for attaching to or creating sessions

## Theme integration

Omarchy renders `zellij.kdl.tpl` from the active theme palette. The `theme-set.d` hook converts it to `~/.config/zellij/themes/omarchy.kdl`, which Zellij hot-reloads when the Omarchy theme changes.

## Requirements

- mise
- Internet access (mise tool download)

## Notes

The repository does not install `zellicat` or the `zc` alias currently.

## Opening links

Zellij enables mouse reporting (alternate screen), so Ghostty forwards clicks to it instead
of handling links itself. To open a URL inside zellij, hold **Ctrl+Shift+Click** (Linux):
Shift escapes zellij's mouse capture, Ctrl is Ghostty's URL modifier on Linux. Outside a
mouse-capturing app (plain shell), plain **Ctrl+Click** works. On macOS the equivalent is
Cmd+Shift+Click.
