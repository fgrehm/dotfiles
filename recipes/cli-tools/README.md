# cli-tools

Standalone command-line tools installed as GitHub release binaries.

## What it does

- Installs [lmk](https://github.com/fgrehm/lmk) to `~/.local/bin/lmk`
- Installs [timr-tui](https://github.com/sectore/timr-tui) to `~/.local/bin/timr-tui`
- Deploys `timr-pomodoro` wrapper to `~/.local/bin/`, which launches timr-tui in pomodoro mode with a red terminal background (set via OSC 11/10, reset on exit) and notifications + blink enabled

## Requirements

- Internet access (GitHub releases)
- `~/.local/bin` on `PATH`

## Notes

Distro-agnostic: no apt/pacman packages, no post-install setup, no config files. These tools
previously lived in the `terminal` recipe alongside the Debian-only terminal emulator setup
(alacritty/tinty); they were split out so they could be enabled on Omarchy without pulling in the
Debian terminal theming.

`timr-pomodoro` wraps the `timr-tui` binary above; it depends on it being installed. The red
background relies on the terminal answering OSC 11/10 (ghostty, alacritty, kitty, foot all do).
