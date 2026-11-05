# 1password

Installs 1Password desktop app and CLI (`op`), then downloads SSH keys from a
configured 1Password vault/item during `chezmoi apply`.

Skipped in containers (they use SSH agent forwarding) and on VMs (the SSH-key
setup requires the `op` CLI and interactive sign-in; the `chezmoi init` vault
prompts are likewise scoped to Omarchy).

On Omarchy, 1Password is preinstalled, so only the SSH-key setup runs (no install step). The apt install script that used to run on the Debian laptop was removed when Debian-as-bare-metal was dropped.

## 1Password setup

SSH keys must be stored as file attachments on a Secure Note in 1Password:

- Item name: configured via `chezmoi init` prompt (e.g. `SSH`)
- Vault: configured via `chezmoi init` prompt (e.g. `Keys`)
- Attachments: `id_ed25519`, `id_ed25519.pub`, and optionally
  `id_ed25519-sign`, `id_ed25519-sign.pub`

## Auth

The SSH key setup script checks `op whoami` before reading any attachments. If the 1Password desktop app is running and unlocked, the CLI uses it automatically. Otherwise the script runs `op signin`, evaluates the returned environment, verifies authentication again, and fails the chezmoi apply if sign-in did not succeed, so the setup can be retried after logging in.
