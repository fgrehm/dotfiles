# omarchy4

Omarchy **4.0**-specific configuration: the Hyprland Lua module overrides. Applies only on Omarchy hosts running the 4.x line (`isOmarchy4` true). Skipped on Omarchy 3.8 (see `omarchy3`) and in containers/non-Omarchy hosts (see `recipes/.recipeignore`).

## Why a separate recipe

Omarchy 4.0 replaced the plain Hyprland `.conf` config system with a Lua module system. Hyprland loads `~/.config/hypr/hyprland.lua`, which bootstraps Omarchy's defaults (`require("default.hypr.omarchy")`) then loads user override modules via `require("hypr.input")`, `require("hypr.bindings")`, etc. Helpers: `hl.unbind`, `hl.config`, `o.bind`, `o.window` (see `/usr/share/omarchy/default/hypr/helpers.lua`). Omarchy 4.0 also dropped waybar for the Quickshell-based Omarchy shell (`~/.config/omarchy/shell.json`) and moved its defaults from `~/.local/share/omarchy/` to `/usr/share/omarchy/` (`OMARCHY_PATH`).

## What lives here

- `~/.config/hypr/hyprland.lua` — the 4.0 entry point. A near-verbatim copy of Omarchy's default entry with one addition: `require("hypr.windowrules")` to load the tracked window-rules module (the default entry does not require one). Tracked in full, so it drifts from upstream if Omarchy changes the default entry — re-sync by diffing against `/usr/share/omarchy/default/hypr/hyprland.lua` after updates. (Same tradeoff as omarchy3's `hyprland.conf`.)
- `~/.config/hypr/bindings.lua` — the binding deltas. Omarchy 4.0's defaults already cover nearly every binding from the old 3.8 `bindings.conf` (terminal, browser, file manager, music, docker, signal, obsidian, 1password, and all webapp bindings), so this file only records the differences: `SUPER+SHIFT+W` → Typora (4.0 default is Omawrite), `SUPER+N` → Obsidian quick note (no 4.0 default), and `SUPER+SLASH` / `SUPER+ALT+SLASH` → the personal 1x ↔ 1.5x monitor scaling cycle (4.0 default is up/down).
- `~/.config/hypr/input.lua` — the one input delta: Caps Lock as Ctrl (`kb_options = compose:paus,ctrl:nocaps`). Omarchy 4.0's default makes Caps a compose key; everything else in the old 3.8 `input.conf` (repeat rate, numlock, touchpad, terminal scroll-touchpad rules) is already the 4.0 default, so only `kb_options` is overridden.
- `~/.config/hypr/windowrules.lua` — float + center rules for transient dialog toolkits (`yad`, `zenity`, `kdialog`), not in Omarchy 4.0's defaults. Mirrors omarchy3's `windowrules.conf`.

## Notes

- The shared `omarchy` recipe owns everything version-neutral: install scripts, starship, voxtype, ghostty (with a templated include path), crib, and `my-monitor-scaling-cycle`. The `my-monitor-scaling-cycle` script is referenced by both this recipe's `bindings.lua` and omarchy3's `bindings.conf`.
- The Omarchy shell (bar/notifications) is **not** customized here yet — Omarchy 4.0's default `shell.json` is used as-is. See `TODO.md` for the deferred bar-customization work.
- There is no `create_local.conf` equivalent for machine-local overrides on 4.0 yet. The tracked `.lua` files are overwritten by `chezmoi apply`, so per-machine tweaks need a follow-up (see `TODO.md`).