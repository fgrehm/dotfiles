# omarchy

Omarchy 4.x customizations for bare-metal hosts. The recipe is selected by `recipes/.recipeignore` and is not applied in containers or on non-Omarchy systems.

## Kept customizations

- `input.lua` keeps Caps Lock as Ctrl, US/US-international layouts, Alt+Shift layout switching, and natural touchpad scrolling. Omarchy's stock 4.5 Hyprland entry point loads this personal module, so the repo does not carry a fork of that entry point.
- `bindings.lua` removes the stock WhatsApp launcher shortcut.
- `run_after_disable-whatsapp-extension.sh` removes Omarchy's WhatsApp-only Chromium extension from any installed Chromium-family flags files, while preserving the other stock extensions and flags. It is safe to run repeatedly.
- `run_onchange_after_remove-unwanted-apps.sh` removes unwanted stock webapps, including Basecamp and WhatsApp, one at a time. Omarchy's removal command accepts one app name per invocation.
- `run_once_after_000-disable-openssh-agent.sh` disables previously enabled OpenSSH and GCR sockets, clears `SSH_AUTH_SOCK`, and removes their environment files only when they still match the known managed contents. This fresh-start setup does not enable an SSH agent. Log out and back in to clear the variable from already-running processes.
- `create_private_dot_config_mise_config.toml` seeds `~/.config/mise/config.toml` only when it does not already exist. It disables Omarchy's unused agent and Basecamp CLI defaults while leaving Claude and Pi available. The file is user-owned after seeding, so existing mise settings are not overwritten.
- `run_once_install-fast-cli-tools.sh` installs ZapFast (`zapfast-bin`).
- Install scripts also set up Brave, Slack, Dropbox, Bun, Rust, lmk, and NVIDIA Vulkan support where applicable.
- `run_once_after_enable-omastats.sh` installs and enables the upstream `crmne.omastats` bar plugin in the right section.
- On Omarchy, the 1Password recipe remains responsible for retrieving configured SSH key attachments. It verifies `op whoami` and signs in before reading the vault; it does not configure an SSH agent.
- `run_once_after_install-restic.sh` installs Restic for the optional WIP backup script.
- `~/.local/bin/wip-backup` makes encrypted, versioned Restic snapshots of explicitly configured local Dropbox paths, project roots, and Screen Time history. See the backup section below before using it.

## Intentionally not deployed

The `omarchy-plugins` recipe is excluded on Omarchy hosts. Its Pomodoro, custom Screen Time, and My Agents plugin sources remain in the repository but are not enabled on the fresh-start system. Existing Screen Time history is not removed, and the backup script can preserve it.

Quick Note, Typora-specific bindings, the copied Hyprland entry point, Omasnap's duplicate install, and custom window rules are not managed here. Omarchy 4.5 supplies Omasnap and its screenshot behavior.

## Backup setup

After applying dotfiles, review `~/.config/wip-backup/config.sh` and set:

- `BACKUP_MOUNTPOINT` to the external drive's mount point.
- `RESTIC_REPOSITORY` to a directory inside that mount.
- `DROPBOX_PATHS` to only the Dropbox folders/files you have made available locally.
- `PROJECT_PATHS` to every project root containing work to preserve, including ignored files.

Create `~/.config/wip-backup/restic-password` with a strong Restic repository password, set permissions to `600`, and store a recovery copy in a password manager separate from the external drive. The script refuses to run unless the external mount is active, the repository is inside that mount, the password file is outside it, and the Restic repository is already initialized. Initialize it manually after configuring the repository and password file:

```bash
source ~/.config/wip-backup/config.sh
export RESTIC_REPOSITORY RESTIC_PASSWORD_FILE
mountpoint -q "$BACKUP_MOUNTPOINT" && restic init
```

Run `wip-backup --dry-run` before the first backup, then `wip-backup` to create a snapshot. Dry-run still reads configured files, so it is not safe to include online-only Dropbox paths. The script does not prune old snapshots or remove source files. Keep online-only Dropbox content out of `DROPBOX_PATHS`; configure only paths that Dropbox has actually made available offline. The script does not query Dropbox's remote inventory or request hydration. To inspect and restore snapshots, use `restic snapshots` and restore to a separate directory first, for example `restic restore latest --target /tmp/wip-restore`.

The backup includes `~/.config/omarchy/screen-time/history.json` when present. That history can contain sensitive app/window-title details if browser-title tracking was enabled. Restic excludes `.ssh` and `.bb` directories nested under configured roots, plus `~/.ssh`, `~/.bb`, `~/.config/bb`, and BB data/storage paths when their environment variables are set. A source path inside one of those sensitive roots is rejected. Keep arbitrarily named private-key files outside configured roots, since Restic cannot identify them by contents without reading every file.

## Notes

- Omarchy commands manage privilege escalation internally; do not prefix them with `sudo`.
- On Omarchy, `omarchy` commands use the system's supported installation and service flows. Package guards keep the setup scripts idempotent.
- The NVIDIA install script is gated by hardware detection; a reboot is required after installing the driver.
