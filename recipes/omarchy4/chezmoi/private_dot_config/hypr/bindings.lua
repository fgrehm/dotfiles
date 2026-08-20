-- Personal keybinding overrides for Omarchy 4.0.
--
-- Omarchy 4.0's defaults (see /usr/share/omarchy/default/hypr/bindings/*.lua)
-- already cover the standard terminal,
-- browser, file manager, music, docker, signal, obsidian, 1password, and all
-- the webapp bindings (ChatGPT, Grok, HEY calendar/email, YouTube, WhatsApp,
-- Google Messages, Google Photos, X). So this file only records the deltas.

-- SUPER+SHIFT+W: Omarchy 4.0 binds this to Omawrite; we want Typora.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- Use Omasnap for the primary screenshot binding.
hl.unbind("PRINT")
o.bind("PRINT", "Screenshot", "omasnap")

