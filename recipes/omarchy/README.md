# omarchy

Omarchy 4.x customizations for bare-metal hosts. The recipe is selected by `recipes/.recipeignore` and is not applied in containers or on non-Omarchy systems.

## Kept customizations

- `input.lua` keeps Caps Lock as Ctrl, US/US-international layouts, and natural touchpad scrolling. Layout switching uses Omarchy 4.5's stock Super+I (forward) and Super+Shift+I (backward), without a custom Alt+Shift toggle. Omarchy's stock Hyprland entry point loads this personal module, so the repo does not carry a fork of that entry point.
- `private_dot_XCompose` deploys `~/.XCompose`, includes Omarchy's standard Compose definitions, and maps US-international acute+c/C to ç/Ç. `run_onchange_after_reload-xcompose.sh.tmpl` reloads Omarchy's input service after the Compose file changes. The old `private_XCompose` filename incorrectly targeted `~/XCompose`; an existing stray file can be removed manually.
- `bindings.lua` removes the stock WhatsApp and Herdr launcher shortcuts, plus the Herdr keybindings menu.
- `run_after_disable-whatsapp-extension.sh` removes Omarchy's WhatsApp-only Chromium extension from any installed Chromium-family flags files, while preserving the other stock extensions and flags. It is safe to run repeatedly.
- `run_once_after_remove-herdr.sh` removes the `herdr` package and stops its server if present.
- `run_onchange_after_remove-unwanted-apps.sh` removes unwanted stock webapps, including Basecamp and WhatsApp, one at a time. Omarchy's removal command accepts one app name per invocation.
- `run_once_after_enable-gcr-ssh-agent.sh` uses Omarchy's supported setup command to enable the GCR SSH agent and configure `SSH_AUTH_SOCK` for host and container use.
- `create_private_dot_config_mise_config.toml` seeds `~/.config/mise/config.toml` only when it does not already exist. It disables Omarchy's unused agent and Basecamp CLI defaults while leaving Claude and Pi available. The file is user-owned after seeding, so existing mise settings are not overwritten.
- `run_once_install-fast-cli-tools.sh` installs ZapFast (`zapfast-bin`).
- Install scripts also set up Brave, Slack, Dropbox, Bun, Rust, lmk, and NVIDIA Vulkan support where applicable.
- `run_once_after_enable-omastats.sh` installs and enables the upstream `crmne.omastats` bar plugin in the right section.
- On Omarchy, the 1Password recipe retrieves configured SSH key attachments after `op vault list --format=json` confirms desktop-integrated vault access. The GCR SSH agent is enabled separately by the Omarchy setup script; Git uses the optional `id_ed25519-sign.pub` key for SSH commit signing when present.

## Intentionally not deployed

The vendored Pomodoro, Screen Time, and My Agents plugins and their legacy recipe have been removed. Existing installed plugin links and bar settings are not migrated or cleaned up. Screen Time usage data remains at `~/.config/omarchy/screen-time/history.json`; add its parent directory to backup sources to preserve it.

Quick Note, Typora-specific bindings, the copied Hyprland entry point, Omasnap's duplicate install, and custom window rules are not managed here. Omarchy 4.5 supplies Omasnap and its screenshot behavior.

## Backup exclusions

`~/.config/omarchy-time-machine/excludes.txt` links to [`config/restic/excludes.txt`](../../config/restic/excludes.txt) in this checkout. Omarchy Time Machine uses that default exclude file unless its configuration explicitly selects another path. The plugin, backup sources, repository, password, and schedule remain manually configured; dotfiles does not start backups.

The rules exclude SSH directories, dependency/build caches, pnpm stores, and common VM/container storage locations. Container volumes and VM disks can contain irreplaceable data; export that data separately or remove the relevant exclusion if it must be backed up. Git repositories, uncommitted work, and BB session data are not broadly excluded. New rules affect future snapshots, not existing ones.

## Notes

- Omarchy commands manage privilege escalation internally; do not prefix them with `sudo`.
- On Omarchy, `omarchy` commands use the system's supported installation and service flows. Package guards keep the setup scripts idempotent.
- The NVIDIA install script is gated by hardware detection; a reboot is required after installing the driver.
