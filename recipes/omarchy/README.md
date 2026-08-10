# omarchy

Omarchy-specific configuration and tweaks. Only applied on Omarchy (Arch-based, Hyprland); ignored on Debian and in containers.

## What it does

- Deploys `~/.config/hypr/input.conf` with Caps Lock remapped to Control (`kb_options = compose:paus,ctrl:nocaps`).
- Deploys `~/.config/waybar/config.jsonc` (top bar layout; clock shows weekday, date, and time).
- Overrides ghostty's window padding to 2px (omarchy's default is 14px) via `~/.config/ghostty/config` + `padding.conf`. `padding.conf` is loaded last (as a `config-file`), so it wins over omarchy's 14px. `window-padding-balance = true` distributes leftover space (viewport not divisible by cell size) across all edges instead of stacking it at the bottom. Padding changes only affect new terminals.
- Sets `SSH_AUTH_SOCK` to the stock OpenSSH agent socket via `~/.config/environment.d/ssh-agent.conf` (`SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket`).
- Enables the stock `ssh-agent.service` user unit via `run_once_enable-ssh-agent.sh` (idempotent; skips if already enabled).
- Removes unwanted apps via `run_once_remove-unwanted-apps.sh` (webapps: Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos; plus obsidian).
- Installs ghostty and sets it as the default terminal via `run_once_install-ghostty.sh` (idempotent; skips if already installed).
- Installs brave and sets it as the default browser via `run_once_install-brave.sh` (idempotent; skips if already installed).
- Installs Slack (`slack-desktop` from the AUR) plus `xdg-desktop-portal-wlr` for Wayland screen sharing via `run_once_install-slack.sh` (idempotent; skips if already installed).
- Installs Dropbox and starts the service via `run_once_install-dropbox.sh` (idempotent; skips if already installed). Must then be authenticated via the web.
- Disables the GNOME filesystem indexer (`localsearch`, formerly `tracker3-miners`) via `run_once_disable-localsearch.sh` (masks `localsearch-3`, `localsearch-control-3`, `localsearch-writeback-3`, and `tinysparql-xdg-portal-3` user services) and deploys `~/.config/autostart/localsearch-3.desktop` with `Hidden=true` as belt-and-suspenders against DBus activation by nautilus. Nothing on Omarchy consumes its index (Walker's file search is self-contained), so it's pure CPU/RAM overhead.

## Notes

- Omarchy manages its own Hyprland configs via `omarchy refresh`. This recipe tracks the user-level overrides so they survive `omarchy refresh`/updates. If a config diverges from omarchy's defaults, re-apply via `chezmoi apply`.
- Ghostty's shipped config is read-only at `~/.local/share/omarchy/config/ghostty/config`. To override it, `~/.config/ghostty/config` includes it via `config-file`, then loads `padding.conf` last (ghostty processes `config-file` entries after the declaring file, in order, so the last one wins).
- The `environment.d` SSH_AUTH_SOCK setting only takes effect after re-login (environment.d is read at systemd user manager startup).
- `AddKeysToAgent yes` is intentionally NOT duplicated here — it lives in the `shell` recipe's `~/.ssh/config`.
