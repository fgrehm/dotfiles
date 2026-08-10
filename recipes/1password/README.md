# 1password

Installs 1Password desktop app and CLI (`op`), then downloads SSH keys from a
configured 1Password vault/item during `chezmoi apply`.

Skipped in containers (they use SSH agent forwarding).

Skipped on Omarchy (1Password is preinstalled there).

## 1Password setup

SSH keys must be stored as file attachments on a Secure Note in 1Password:

- Item name: configured via `chezmoi init` prompt (e.g. `SSH`)
- Vault: configured via `chezmoi init` prompt (e.g. `Keys`)
- Attachments: `id_ed25519`, `id_ed25519.pub`, and optionally
  `id_ed25519-sign`, `id_ed25519-sign.pub`

## Auth

If the 1Password desktop app is running and unlocked, the CLI uses it automatically.
Otherwise, the SSH key setup script will call `eval "$(op signin)"` to prompt for
interactive authentication.
