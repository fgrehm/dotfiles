# omarchy

Omarchy-specific configuration and tweaks. Only applied on Omarchy (Arch-based, Hyprland); ignored on Debian and in containers.

## What it does

- Deploys `~/.config/hypr/input.conf` with Caps Lock remapped to Control (`kb_options = compose:paus,ctrl:nocaps`).
- Sets `SSH_AUTH_SOCK` to the stock OpenSSH agent socket via `~/.config/environment.d/ssh-agent.conf` (`SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket`).
- Enables the stock `ssh-agent.service` user unit via `run_once_enable-ssh-agent.sh` (idempotent; skips if already enabled).
- Removes unwanted apps via `run_once_remove-unwanted-apps.sh` (webapps: Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos; plus obsidian).

## Notes

- Omarchy manages its own Hyprland configs via `omarchy refresh`. This recipe tracks the user-level overrides so they survive `omarchy refresh`/updates. If a config diverges from omarchy's defaults, re-apply via `chezmoi apply`.
- The `environment.d` SSH_AUTH_SOCK setting only takes effect after re-login (environment.d is read at systemd user manager startup).
- `AddKeysToAgent yes` is intentionally NOT duplicated here — it lives in the `shell` recipe's `~/.ssh/config`.
