# kde

KDE Plasma 6 keyboard and input configuration.

## What it does

- Configures keyboard layouts: US and US International (dead keys)
- Remaps Caps Lock to Ctrl (`caps:ctrl_modifier`)
- Sets Super+Space as layout switch shortcut
- Fixes cedilla input for `en_US` locale (dead_acute + c = c-cedilla, not c-acute)
- Deploys `~/.config/environment.d/cedilla.conf` (GTK/QT input module env vars)

## Cedilla fix details

On Debian with `en_US.UTF-8` locale and US-intl dead keys, the GTK cedilla
input module does not activate because 'en' is missing from its locale filter.
The configure-cedilla script patches:

1. GTK immodules cache: adds 'en' to the cedilla locale list
2. X11 Compose file: replaces c-acute with c-cedilla for dead_acute sequences

The environment.d file sets `GTK_IM_MODULE=cedilla` and `QT_IM_MODULE=cedilla`.

## Requirements

- Debian 13 (Trixie), KDE Plasma 6
- Skipped in containers via `.recipeignore`
