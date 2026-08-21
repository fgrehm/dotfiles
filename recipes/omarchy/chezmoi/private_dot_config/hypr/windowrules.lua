-- Personal Hyprland window rules for Omarchy 4.0.
--
-- Loaded by ~/.config/hypr/hyprland.lua after Omarchy's default window rules
-- (default.hypr.windows + default.hypr.apps), so these win.
--
-- Float + center transient dialog toolkits so they don't get tiled. Match the
-- toolkit class, not the calling app. Not in Omarchy 4.0's defaults. Mirrors
-- the previous Hyprland configuration.

o.window("^(yad|zenity|kdialog)$", { float = true, center = true })

-- Keep the Omasnap layer surface from receiving Hyprland animations.
hl.layer_rule({
  match = "^omasnap$",
  no_anim = true,
  animation = "none",
})