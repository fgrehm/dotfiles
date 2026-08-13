-- Personal Hyprland window rules for Omarchy 4.0.
--
-- Loaded by ~/.config/hypr/hyprland.lua after Omarchy's default window rules
-- (default.hypr.windows + default.hypr.apps), so these win.
--
-- Float + center transient dialog toolkits so they don't get tiled. Match the
-- toolkit class, not the calling app. Not in Omarchy 4.0's defaults. Mirrors
-- the omarchy3 windowrules.conf.

o.window("^(yad|zenity|kdialog)$", { float = true, center = true })