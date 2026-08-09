# omarchy

Omarchy-specific configuration and tweaks. Only applied on Omarchy (Arch-based,
Hyprland); ignored on Debian and in containers.

## What it does

- Deploys `~/.config/hypr/input.conf` with Caps Lock remapped to Control
  (`kb_options = compose:paus,ctrl:nocaps`).

## Notes

- Omarchy manages its own Hyprland configs via `omarchy refresh`. This recipe
  tracks the user-level overrides so they survive `omarchy refresh`/updates.
  If a config diverges from omarchy's defaults, re-apply via `chezmoi apply`.
