-- Personal input overrides for Omarchy 4.0.
--
-- Omarchy 4.0's default input config (see /usr/share/omarchy/default/hypr/input.lua)
-- already supplies the standard repeat rate and
-- repeat_delay 250, numlock_by_default, clickfinger_behavior, scroll_factor 0.4,
-- and the terminal scroll_touchpad window rules. The one real difference is
-- Caps Lock: Omarchy 4.0 makes Caps a compose key, while we want Caps as
-- Ctrl. The stock emoji picker remains available through SUPER + CTRL + E.
-- Only kb_options is overridden here; Hyprland applies config fields
-- incrementally, so the other defaults are kept.

hl.config({
  input = {
    kb_layout = "us,us",
    kb_variant = ",intl",
    kb_options = "ctrl:nocaps,grp:alt_shift_toggle",
    touchpad = {
      natural_scroll = true,
    },
  },
})
