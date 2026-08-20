# omarchy4

Omarchy **4.0**-specific configuration: the Hyprland Lua module overrides. Applies only on Omarchy hosts running the 4.x line (`isOmarchy4` true) and is skipped in containers/non-Omarchy hosts (see `recipes/.recipeignore`).

## Why a separate recipe

Omarchy 4.0 replaced the plain Hyprland `.conf` config system with a Lua module system. Hyprland loads `~/.config/hypr/hyprland.lua`, which bootstraps Omarchy's defaults (`require("default.hypr.omarchy")`) then loads user override modules via `require("hypr.input")`, `require("hypr.bindings")`, etc. Helpers: `hl.unbind`, `hl.config`, `o.bind`, `o.window` (see `/usr/share/omarchy/default/hypr/helpers.lua`). Omarchy 4.0 also dropped waybar for the Quickshell-based Omarchy shell (`~/.config/omarchy/shell.json`) and moved its defaults from `~/.local/share/omarchy/` to `/usr/share/omarchy/` (`OMARCHY_PATH`).

## What lives here

- `~/.config/hypr/hyprland.lua` — the 4.0 entry point. A near-verbatim copy of Omarchy's default entry with one addition: `require("hypr.windowrules")` to load the tracked window-rules module (the default entry does not require one). Tracked in full, so it drifts from upstream if Omarchy changes the default entry — re-sync by diffing against `/usr/share/omarchy/config/hypr/hyprland.lua` after updates.
- `~/.config/hypr/bindings.lua` — the binding deltas. Omarchy 4.0's defaults already cover nearly every standard binding (terminal, browser, file manager, music, Docker, Signal, Obsidian, 1Password, and all webapp bindings), so this file only records the Typora override (`SUPER+SHIFT+W`; 4.0 default is Omawrite).
- `~/.config/hypr/input.lua` — input deltas: Caps Lock as Ctrl (`kb_options = ctrl:nocaps`) and natural touchpad scrolling. Omarchy 4.0's default makes Caps a compose key; the remaining default input settings are preserved. The stock emoji picker remains available via `SUPER + CTRL + E`.
- `~/.config/hypr/windowrules.lua` — float + center rules for transient dialog toolkits (`yad`, `zenity`, `kdialog`), not in Omarchy 4.0's defaults. Maintained as a Lua module for Omarchy 4.

## Notes

- The shared `omarchy` recipe owns everything version-neutral: install scripts and crib.
- The Omarchy shell (bar/notifications) is **not** customized here yet — Omarchy 4.0's default `shell.json` is used as-is. See `TODO.md` for the deferred bar-customization work.
- There is no `create_local.conf` equivalent for machine-local overrides on 4.0 yet. The tracked `.lua` files are overwritten by `chezmoi apply`, so per-machine tweaks need a follow-up (see `TODO.md`).