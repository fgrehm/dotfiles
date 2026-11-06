# omarchy

Omarchy 4.x customizations for bare-metal hosts. The recipe is selected by `recipes/.recipeignore` and is not applied in containers or on non-Omarchy systems.

## Kept customizations

- `input.lua` keeps Caps Lock as Ctrl, US/US-international layouts, Alt+Shift layout switching, and natural touchpad scrolling. Omarchy's stock 4.5 Hyprland entry point loads this personal module, so the repo does not carry a fork of that entry point.
- `bindings.lua` removes the stock WhatsApp launcher shortcut.
- `run_after_disable-whatsapp-extension.sh` removes Omarchy's WhatsApp-only Chromium extension from any installed Chromium-family flags files, while preserving the other stock extensions and flags. It is safe to run repeatedly.
- `run_onchange_after_remove-unwanted-apps.sh` removes unwanted stock webapps, including Basecamp and WhatsApp, one at a time. Omarchy's removal command accepts one app name per invocation.
- `run_once_after_enable-gcr-ssh-agent.sh` uses Omarchy's supported setup command to enable the GCR SSH agent and configure `SSH_AUTH_SOCK` for host and container use.
- `create_private_dot_config_mise_config.toml` seeds `~/.config/mise/config.toml` only when it does not already exist. It disables Omarchy's unused agent and Basecamp CLI defaults while leaving Claude and Pi available. The file is user-owned after seeding, so existing mise settings are not overwritten.
- `run_once_install-fast-cli-tools.sh` installs ZapFast (`zapfast-bin`).
- Install scripts also set up Brave, Slack, Dropbox, Bun, Rust, lmk, and NVIDIA Vulkan support where applicable.
- `run_once_after_enable-omastats.sh` installs and enables the upstream `crmne.omastats` bar plugin in the right section.
- On Omarchy, the 1Password recipe remains responsible for retrieving configured SSH key attachments. It verifies `op whoami` and signs in before reading the vault; it does not configure an SSH agent.

## Intentionally not deployed

The `omarchy-plugins` recipe is excluded on Omarchy hosts. Its Pomodoro, custom Screen Time, and My Agents plugin sources remain in the repository but are not enabled on the fresh-start system. Existing Screen Time history is not removed.

Quick Note, Typora-specific bindings, the copied Hyprland entry point, Omasnap's duplicate install, and custom window rules are not managed here. Omarchy 4.5 supplies Omasnap and its screenshot behavior.

## Notes

- Omarchy commands manage privilege escalation internally; do not prefix them with `sudo`.
- On Omarchy, `omarchy` commands use the system's supported installation and service flows. Package guards keep the setup scripts idempotent.
- The NVIDIA install script is gated by hardware detection; a reboot is required after installing the driver.
