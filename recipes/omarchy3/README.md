# omarchy3

Omarchy **3.8**-specific configuration: the Hyprland `.conf` stack, waybar bar config, and the waybar restart trigger. Applies only on Omarchy hosts running the 3.x line (`isOmarchy` true, `isOmarchy4` false). Skipped on Omarchy 4.0 (see `omarchy4`) and in containers/non-Omarchy hosts (see `recipes/.recipeignore`).

## Why a separate recipe

Omarchy 4.0 replaced the plain Hyprland `.conf` config system with a Lua module system (`~/.config/hypr/*.lua` loaded via `require()`), dropped waybar in favor of the Quickshell-based Omarchy shell, and moved its defaults from `~/.local/share/omarchy/` to `/usr/share/omarchy/`. The 3.8 config files here are sourced via `source =` directives that 4.0 never loads, so they are kept in this version-gated recipe and never deployed on 4.0.

## What lives here

- `~/.config/hypr/hyprland.conf` — the 3.8 entry point. Sources omarchy's defaults from `~/.local/share/omarchy/default/hypr/*.conf`, then the tracked user overrides (`input.conf`, `bindings.conf`, `looknfeel.conf`, `autostart.conf`, `windowrules.conf`), then omarchy's toggle flags, then `local.conf`. Tracked in full, so if omarchy 3.8 upstream changes its default `hyprland.conf` the tracked copy drifts and needs re-syncing.
- `~/.config/hypr/bindings.conf` — application + webapp bindings and the custom `Super+/` monitor scaling cycle (1x ↔ 1.5x via `~/.local/bin/my-monitor-scaling-cycle`, which lives in the shared `omarchy` recipe since it's version-neutral). Also overrides omarchy's default `Super+N` (Neovim) with the Obsidian quick-note binding.
- `~/.config/hypr/input.conf` — Caps Lock as Ctrl (`kb_options = compose:paus,ctrl:nocaps`), numlock, repeat rate, touchpad settings, and terminal scroll-touchpad window rules.
- `~/.config/hypr/windowrules.conf` — float + center rules for transient dialog toolkits (`yad`, `zenity`, `kdialog`).
- `~/.config/hypr/local.conf` — seeded once via chezmoi's `create_` attribute for machine-local overrides; local edits are preserved across `chezmoi apply`. Sourced last by `hyprland.conf`.
- `~/.config/waybar/config.jsonc` — top bar layout (clock shows weekday, date, and time; includes the voxtype module). Waybar is the bar on Omarchy 3.8.
- `run_onchange_after_restart-waybar.sh.tmpl` — restarts waybar whenever the bar config changes (waybar does not auto-reload). Embeds the config hash so it re-runs on changes.

## Notes

- `omarchy restart waybar` exists on 3.8 but not on 4.0 (4.0 uses `omarchy restart shell`); that's why this script is version-gated to 3.8.
- The shared `omarchy` recipe owns the install scripts, starship, voxtype, ghostty, crib, and `my-monitor-scaling-cycle` — all of which work on both versions.