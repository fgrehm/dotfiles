# cli-tools

Standalone command-line tools installed as GitHub release binaries.

## What it does

- Installs [lmk](https://github.com/fgrehm/lmk) to `~/.local/bin/lmk`
- Installs [timr-tui](https://github.com/sectore/timr-tui) to `~/.local/bin/timr-tui`

## Requirements

- Internet access (GitHub releases)
- `~/.local/bin` on `PATH`

## Notes

Distro-agnostic: no apt/pacman packages, no post-install setup, no config files. These tools
previously lived in the `terminal` recipe alongside the Debian-only terminal emulator setup
(alacritty/tinty); they were split out so they could be enabled on Omarchy without pulling in the
Debian terminal theming.
