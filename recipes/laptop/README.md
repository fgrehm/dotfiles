# laptop

Random terminal tooling for laptop/baremetal use. Skipped in containers via `.recipeignore`.

## What it does

- Installs the [crib](https://github.com/fgrehm/crib) CLI to `~/.local/bin/crib` from GitHub releases ("Just Enough Devcontainers": reads `.devcontainer/devcontainer.json`, builds the container, and runs it)
- Deploys `~/.config/crib/config.toml`

## Requirements

- Debian 13 (Trixie) or equivalent Linux
