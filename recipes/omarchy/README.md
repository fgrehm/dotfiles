# omarchy

Version-neutral Omarchy configuration and tweaks: install scripts and configs that work identically on Omarchy 3.8 and 4.0. Always applied on Omarchy hosts (bare-metal/laptop target). Version-specific Hyprland/bar config lives in [`omarchy3`](../omarchy3) and [`omarchy4`](../omarchy4); this recipe is gated to Omarchy by `recipes/.recipeignore` (skipped in containers and on non-Omarchy hosts).

## What does what

Shared across both Omarchy versions:

- **Install scripts** (all idempotent, guarded with `command -v`):
  - `run_once_install-ghostty.sh.tmpl` — installs ghostty and sets it as the default terminal (`omarchy install terminal ghostty` + `omarchy default terminal ghostty`). **Skipped on Omarchy 4.0** (via a template guard), where foot is the default terminal and supports images via sixel — ghostty's image support was the 3.8 use case. The ghostty config files are also skipped on 4.0 via `.chezmoiignore`.
  - `run_once_install-brave.sh` — installs brave and sets it as the default browser (`omarchy install browser brave` + `omarchy default browser brave`).
  - `run_once_install-slack.sh` — installs `slack-desktop` (AUR) plus `xdg-desktop-portal-wlr` for Wayland screen sharing.
  - `run_once_install-dropbox.sh.tmpl` — installs Dropbox and starts the service. Uses `omarchy install service dropbox` on 4.0 (the command changed from 3.8's `omarchy install dropbox`). Must then be authenticated via the web.
  - `run_once_after_install-voxtype.sh.tmpl` — installs Voxtype dictation (`wtype` + `voxtype-bin`), downloads the AI model (~150MB), enables GPU acceleration only when a discrete GPU is present (2+ display controllers in `lspci`, same heuristic as `omarchy-hw-hybrid-gpu`), and enables/starts the deployed systemd user service. Restarts the bar afterward via a version-guarded command (`omarchy restart shell` on 4.0, `omarchy restart waybar` on 3.8).
  - `run_once_enable-ssh-agent.sh` — enables the stock `ssh-agent.service` user unit.
  - `run_once_install-ssh-askpass.sh` — installs Seahorse and its graphical SSH key passphrase prompt.
  - `run_once_disable-localsearch.sh` — masks the GNOME filesystem indexer (`localsearch-3` and friends) and deploys `~/.config/autostart/localsearch-3.desktop` with `Hidden=true` as belt-and-suspenders against DBus activation by nautilus.
  - `run_once_remove-unwanted-apps.sh` — removes unwanted omarchy webapps (Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos, WhatsApp) in a single `omarchy-webapp-remove` call.
- `run_onchange_after_restart-voxtype.sh.tmpl` — restarts the voxtype daemon (and the bar, version-guarded) whenever the voxtype config, service, or gpu drop-in changes. Embeds all three hashes.
- `~/.config/voxtype/config.toml` — customized voxtype config (hotkey `HOME` push-to-talk, whisper `mode = "local"`, output `auto_submit`/`shift_enter_newlines`/`pre_type_delay_ms`, `[text]` section, `engine = "whisper"`). The install script runs as `run_once_after_` so this config is in place before `voxtype setup` runs.
- `~/.config/systemd/user/voxtype.service` + `voxtype.service.d/gpu.conf` — the tracked voxtype systemd user service and an NVIDIA drop-in (`VOXTYPE_VULKAN_DEVICE=nvidia`) pinned to hybrid-GPU laptops. The drop-in is skipped via `.chezmoiignore` when there's no NVIDIA GPU (`hasNvidiaGPU`).
- `~/.config/environment.d/ssh-agent.conf` — points `SSH_AUTH_SOCK` at the stock OpenSSH agent socket and configures Seahorse's graphical SSH askpass prompt. Takes effect after re-login.
- `~/.config/starship.toml` — minimal prompt with a conditional newline (`add_newline = false` plus a `custom.line_break` module that inserts a line break before `❯` only inside git repos).
- `~/.config/user-dirs.dirs` + `~/.config/gtk-3.0/bookmarks.tmpl` — lowercase `~/projects` instead of omarchy's default `~/Projects`.
- `~/.config/ghostty/config.tmpl` — includes omarchy's default ghostty config then loads `padding.conf` and `keybinds.conf` last (ghostty processes `config-file` entries after the declaring file, in order, so the last one wins). The include path is templated by Omarchy version: `~/.local/share/omarchy/...` on 3.8, `/usr/share/omarchy/...` on 4.0 (Omarchy 4.0 moved its defaults to `OMARCHY_PATH`). **Skipped on 4.0** via `.chezmoiignore` (ghostty isn't installed there).
- `~/.config/ghostty/padding.conf` — reduces omarchy's 14px window padding to 2px (`window-padding-balance = true`).
- `~/.config/ghostty/keybinds.conf` — `shift+enter=text:\n` so TUIs insert a newline instead of submitting (mirrors the alacritty binding in the terminal recipe).
- `~/.local/bin/my-monitor-scaling-cycle` — personal 1x ↔ 1.5x monitor scaling cycle (standalone; calls `hyprctl` directly). Bound by both `omarchy3` (via `bindings.conf`) and `omarchy4` (via `bindings.lua`). Lives here because it's version-neutral.
- `~/.local/bin/obsidian-quick-note` — quick-note shortcut for the Obsidian "Main" vault (ensures Obsidian is running/focused, then creates a timestamped note via the `obsidian://new` URI). Bound to `Super+N` by both `omarchy3` and `omarchy4`.
- `~/.local/bin/crib` (via `.chezmoiexternals/crib.toml`) + `~/.config/crib/config.toml` — the [crib](https://github.com/fgrehm/crib) CLI ("Just Enough Devcontainers"). Bare-metal-only; lives here because Omarchy is the only bare-metal target.

## Version-specific recipes

- [`omarchy3`](../omarchy3) — Hyprland `.conf` stack + waybar bar config (3.8 only).
- [`omarchy4`](../omarchy4) — Hyprland `.lua` overrides (4.0 only).

## Notes

- `omarchy` commands handle sudo internally (`omarchy pkg add`, `omarchy install`, ... declare `requires-sudo=true` and call `sudo` themselves). Do NOT prefix `$SUDO` — call `omarchy ...` directly.
- Omarchy has no `wget` by default; install scripts use `omarchy`/`pacman` rather than fetching directly.
- The `environment.d` SSH_AUTH_SOCK setting only takes effect after re-login (environment.d is read at systemd user manager startup).
- `AddKeysToAgent yes` is intentionally NOT duplicated here — it lives in the `shell` recipe's `~/.ssh/config`.
- `gpg-agent-ssh.socket` (GnuPG SSH emulation) is active by default and can override `SSH_AUTH_SOCK` via `ExecStartPost`; mask it if it hijacks the socket (see BACKLOG.md).