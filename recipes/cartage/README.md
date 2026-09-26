# cartage

[Cartage](https://github.com/fgrehm/cartage) container-to-host bridge: installs the binary and
wires it up for the current environment.

## What it does

- Installs the cartage binary to `~/.local/bin/cartage` from GitHub releases (containers and Omarchy only)
- **Container**: creates symlinks in `~/.local/bin/` so `pbcopy`, `pbpaste`, `notify-send`, `yad`,
  and `xdg-open` all resolve to cartage (which forwards the intent to the host daemon over a socket)
- **Bare metal (Omarchy)**: deploys `~/.config/systemd/user/cartage.service` and enables it via systemd so the
  daemon starts with the graphical session
- **VMs** (non-container, non-Omarchy): skipped entirely. There is no host daemon socket to forward to,
  the client symlinks are useless, and the daemon would run with no clients. A `run_once_before_remove-cartage-vm.sh.tmpl`
  cleanup script removes the binary and service an earlier apply left behind on such machines.

## Requirements

- wget
- Internet access (GitHub releases)
- **Bare metal only**: systemd user session, graphical session target

## Template variables

- `isContainer` (bool) - controls which half of the recipe is deployed
- `isOmarchy` (bool) - the daemon half requires an Omarchy desktop; VMs get nothing

## Config

No config files. The daemon listens on `$XDG_RUNTIME_DIR/cartage.sock` by default; containers must
mount this socket path in order to reach the host daemon.
