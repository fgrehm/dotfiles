# omarchy

Omarchy configuration and tweaks for the 4.x release. Always applied on Omarchy hosts (bare-metal/laptop target). This recipe is gated to Omarchy by `recipes/.recipeignore` (skipped in containers and on non-Omarchy hosts).

## What does what

Shared across Omarchy 4:

- **Install scripts** (all idempotent, guarded with `command -v`):
  - `run_once_install-brave.sh` — installs brave and sets it as the default browser (`omarchy install browser brave` + `omarchy default browser brave`).
  - `run_once_install-slack.sh` — installs `slack-desktop` (AUR) plus `xdg-desktop-portal-wlr` for Wayland screen sharing.
  - `run_once_install-dropbox.sh.tmpl` — installs Dropbox and starts the service. Uses Omarchy 4's `omarchy install service dropbox` command. Must then be authenticated via the web.
  - `run_once_enable-ssh-agent.sh` — enables the stock `ssh-agent.service` user unit.
  - `run_once_install-ssh-askpass.sh` — installs Seahorse and its graphical SSH key passphrase prompt.
  - `run_once_disable-localsearch.sh` — masks the GNOME filesystem indexer (`localsearch-3` and friends) and deploys `~/.config/autostart/localsearch-3.desktop` with `Hidden=true` as belt-and-suspenders against DBus activation by nautilus.
  - `run_once_remove-unwanted-apps.sh` — removes unwanted omarchy webapps (Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos, WhatsApp) in a single `omarchy-webapp-remove` call.
  - `run_once_install-lmk.sh.tmpl` — installs the pinned `lmk` command-line tool through Omarchy mise's GitHub backend.
  - `run_once_install-rust.sh.tmpl` — installs the Rust toolchain (`rustc` and `cargo`) through Omarchy mise.
  - `run_once_install-bun.sh.tmpl` — installs Bun through Omarchy mise.
  - `run_once_install-nvidia-vulkan.sh.tmpl` — on NVIDIA machines, installs the proprietary DKMS driver and Vulkan tooling, then rebuilds DKMS modules. A reboot is required afterward.
- `~/.config/environment.d/ssh-agent.conf` — points `SSH_AUTH_SOCK` at the stock OpenSSH agent socket and configures Seahorse's graphical SSH askpass prompt. Takes effect after re-login.
- `~/.local/bin/crib` (via `.chezmoiexternals/crib.toml`) + `~/.config/crib/config.toml` — the [crib](https://github.com/fgrehm/crib) CLI ("Just Enough Devcontainers"). Bare-metal-only; lives here because Omarchy is the only bare-metal target.
- `run_once_install-omasnap.sh` + `.chezmoiexternals/omasnap.toml` — install Omasnap's runtime dependencies and pinned screenshot binary/desktop entry.

## Hyprland configuration

- `~/.config/hypr/hyprland.lua` — the Omarchy 4 entry point, loading Omarchy defaults and the tracked user modules.
- `~/.config/hypr/bindings.lua` — custom Typora and personal bindings.
- `~/.config/hypr/input.lua` — Caps Lock as Ctrl and natural touchpad scrolling.
- `~/.config/hypr/windowrules.lua` — float and center rules for transient dialog toolkits.

## Notes

- `omarchy` commands handle sudo internally (`omarchy pkg add`, `omarchy install`, ... declare `requires-sudo=true` and call `sudo` themselves). Do NOT prefix `$SUDO` — call `omarchy ...` directly.
- Omarchy has no `wget` by default; install scripts use `omarchy`/`pacman` rather than fetching directly.
- The `environment.d` SSH_AUTH_SOCK setting only takes effect after re-login (environment.d is read at systemd user manager startup).
- `AddKeysToAgent yes` is intentionally NOT duplicated here — it lives in the `shell` recipe's `~/.ssh/config`.
- `gpg-agent-ssh.socket` (GnuPG SSH emulation) is active by default and can override `SSH_AUTH_SOCK` via `ExecStartPost`; mask it if it hijacks the socket (see BACKLOG.md).
- NVIDIA setup is detected from `lspci`; verify after reboot with `nvidia-smi` and `vulkaninfo --summary`.