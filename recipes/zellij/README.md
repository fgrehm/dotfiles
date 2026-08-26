# zellij

[Zellij](https://zellij.dev) terminal multiplexer.

## What it does

- Installs Zellij through mise (`omarchy-mise-install` on Omarchy)
- Deploys `~/.config/zellij/config.kdl` with custom keybindings, full pane borders, and Omarchy theme integration
- Adds the `zac` shell helper for attaching to or creating sessions
- Uses 8px Foot padding, shared with non-Zellij Foot applications

## Keybindings

The prefix is `Ctrl+Space`, matching Omarchy's Tmux and Herdr configurations. `Alt+Up` and `Alt+Down` are intentionally unbound so pi can use them for queued-message steering. Pane focus is available through `Ctrl+Alt+Arrow` and `Alt+H/J/K/L`. `Ctrl+PageUp/PageDown` switches tabs from normal, scroll, and search modes.

## Theme integration

Omarchy renders `zellij.kdl.tpl` from the active theme palette. The `theme-set.d` hook converts it to `~/.config/zellij/themes/omarchy.kdl`, which Zellij hot-reloads when the Omarchy theme changes. A `create_` seed file provides a bootstrap theme before the first theme change. Pane selection uses Zellij's `text_selected` colors, with the Omarchy accent as a high-contrast background.

Zellij pane frames use the `full` style. Foot provides the surrounding terminal padding through `pad=8x8` in the Omarchy recipe.

## Requirements

- mise
- Internet access (mise tool download)
- Omarchy theme integration requires Omarchy 4.x; the Zellij configuration itself also works outside Omarchy

## Notes

The repository does not install `zellicat` or the `zc` alias currently.

## Opening links

Zellij enables mouse reporting (alternate screen), so Ghostty forwards clicks to it instead
of handling links itself. To open a URL inside zellij, hold **Ctrl+Shift+Click** (Linux):
Shift escapes zellij's mouse capture, Ctrl is Ghostty's URL modifier on Linux. Outside a
mouse-capturing app (plain shell), plain **Ctrl+Click** works. On macOS the equivalent is
Cmd+Shift+Click.
