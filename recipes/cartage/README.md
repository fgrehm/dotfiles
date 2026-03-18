# cartage

[Cartage](https://github.com/fgrehm/cartage) container-to-host bridge: installs the binary and
wires it up for the current environment.

## What it does

- Installs the cartage binary to `~/.local/bin/cartage` from GitHub releases
- **Container**: creates symlinks in `~/.local/bin/` so `pbcopy`, `pbpaste`, `notify-send`, `yad`,
  and `xdg-open` all resolve to cartage (which forwards the intent to the host daemon over a socket)
- **Laptop**: deploys `~/.config/systemd/user/cartage.service` and enables it via systemd so the
  daemon starts with the graphical session

## Requirements

- Debian 13 (Trixie)
- wget
- Internet access (GitHub releases)
- **Laptop only**: systemd user session, graphical session target

## Template variables

- `isContainer` (bool) - controls which half of the recipe is deployed

## Config

No config files. The daemon listens on `$XDG_RUNTIME_DIR/cartage.sock` by default; containers must
mount this socket path in order to reach the host daemon.
