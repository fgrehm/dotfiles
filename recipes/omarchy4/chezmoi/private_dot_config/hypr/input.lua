-- Personal input overrides for Omarchy 4.0.
--
-- Omarchy 4.0's default input config (see /usr/share/omarchy/default/hypr/input.lua)
-- already matches the old 3.8 input.conf for almost everything: repeat_rate 40,
-- repeat_delay 250, numlock_by_default, clickfinger_behavior, scroll_factor 0.4,
-- and the terminal scroll_touchpad window rules. The one real difference is
-- Caps Lock: Omarchy 4.0 makes Caps a compose key (compose:caps,shift:both_capslock_cancel),
-- while we want Caps as Ctrl (ctrl:nocaps). Only kb_options is overridden here;
-- Hyprland applies config fields incrementally, so the other defaults are kept.

hl.config({
  input = {
    kb_options = "compose:paus,ctrl:nocaps",
  },
})