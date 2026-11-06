-- Overrides Omarchy's default: /usr/share/omarchy/default/hypr/input.lua
-- Keep Caps Lock as Ctrl; use Omarchy 4.5's Super+I for layout switching.

hl.config({
  input = {
    kb_layout = "us,us",
    kb_variant = ",intl",
    kb_options = "ctrl:nocaps",
    touchpad = {
      natural_scroll = true,
    },
  },
})
