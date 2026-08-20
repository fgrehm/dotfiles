-- Overrides omarchy's default entry: /usr/share/omarchy/config/hypr/hyprland.lua
--
-- This is a near-verbatim copy of the omarchy 4.0 default entry with one
-- addition: `require("hypr.windowrules")` to load the tracked window-rules
-- module. Omarchy's default entry does not require a user window-rules file.
--
-- Drift tradeoff: because this file is tracked in full, an `omarchy update`
-- that changes the default entry will not propagate here. Re-sync by diffing
-- against `/usr/share/omarchy/config/hypr/hyprland.lua` after updates and
-- re-applying via `chezmoi apply`.

-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Personal window rules. Sourced after Omarchy's default window rules
-- (default.hypr.windows, required by default.hypr.omarchy above) so these win.
require("hypr.windowrules")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })