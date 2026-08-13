-- Personal keybinding overrides for Omarchy 4.0.
--
-- Omarchy 4.0's defaults (see /usr/share/omarchy/default/hypr/bindings/*.lua)
-- already cover almost every binding from the old 3.8 bindings.conf: terminal,
-- browser, file manager, music, docker, signal, obsidian, 1password, and all
-- the webapp bindings (ChatGPT, Grok, HEY calendar/email, YouTube, WhatsApp,
-- Google Messages, Google Photos, X). So this file only records the deltas.

-- SUPER+SHIFT+W: Omarchy 4.0 binds this to Omawrite; we want Typora.
hl.unbind("SUPER + SHIFT + W")
o.bind("SUPER + SHIFT + W", "Typora", { launch = "typora --enable-wayland-ime" })

-- SUPER+N: quick note in the Obsidian "Main" vault (obsidian-quick-note lives
-- in ~/.local/bin, deployed by the shared omarchy recipe). Omarchy 4.0 has no
-- default on SUPER+N, so no unbind is needed.
o.bind("SUPER + N", "Quick note", "obsidian-quick-note")

-- SUPER+/ and SUPER+ALT+/: override Omarchy 4.0's default monitor-scaling
-- up/down with the personal 1x <-> 1.5x cycle (my-monitor-scaling-cycle lives
-- in ~/.local/bin, deployed by the shared omarchy recipe).
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")
o.bind("SUPER + SLASH", "Cycle monitor scaling", "~/.local/bin/my-monitor-scaling-cycle")
o.bind("SUPER + ALT + SLASH", "Cycle monitor scaling backwards", "~/.local/bin/my-monitor-scaling-cycle --reverse")