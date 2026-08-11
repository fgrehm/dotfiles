# webapps

Standalone desktop web apps via [please-make-me-an-app](https://github.com/fgrehm/please-make-me-an-app) (pmma).

## What it does

- Installs the `please-make-me-an-app` CLI to `~/.local/bin/please-make-me-an-app` (GitHub release binary, pinned version).
- Installs the runtime dependencies (WebKitGTK, GTK3, libayatana-appindicator) via the distro package manager.
- Deploys the WhatsApp webapp config to `~/.config/please-make-me-an-app/apps/whatsapp.yaml` and generates its `.desktop` launcher entry.

## Requirements

- Internet access (GitHub releases + distro packages)
- `~/.local/bin` on `PATH`

## Notes

- Runs on both Debian and Omarchy; ignored in containers (no display server).
- The `.desktop` entry is regenerated whenever `whatsapp.yaml` changes (config hash embedded in the install script).
- On Omarchy, the built-in WhatsApp webapp is removed (see the `omarchy` recipe's `run_once_remove-unwanted-apps.sh`) so it doesn't collide with the pmma one.
