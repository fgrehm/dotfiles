# 1password

Installs 1Password desktop app and CLI (`op`), then downloads SSH keys from a
configured 1Password vault/item during `chezmoi apply`.

Skipped in containers (they use SSH agent forwarding) and on VMs (the SSH-key
setup requires the `op` CLI and interactive sign-in; the `chezmoi init` vault
prompts are likewise scoped to Omarchy).

On Omarchy, 1Password is not installed by default. Install it from Omarchy's **Install > Service > 1Password** menu before applying dotfiles.

## 1Password setup

SSH keys must be stored as file attachments on a Secure Note in 1Password:

- Item name: configured via `chezmoi init` prompt (e.g. `SSH`)
- Vault: configured via `chezmoi init` prompt (e.g. `Keys`)
- Attachments: `id_ed25519`, `id_ed25519.pub`, and optionally
  `id_ed25519-sign`, `id_ed25519-sign.pub`

## Preflight and auth

Before `chezmoi apply`, run `scripts/preflight-1password.sh`. It fails early if `op` is missing or cannot access vaults. On Omarchy, install the service from **Install > Service > 1Password** first. Then sign in to the desktop app, enable **Settings > Developer > Integrate with 1Password CLI**, and rerun the preflight. It checks `op vault list --format=json`; `op whoami` is not suitable for this desktop-integrated session because the CLI may report that the account is not signed in even while vault access works.

During apply, SSH-key setup repeats the vault-access check before reading the configured attachments. It fails apply if `op` is missing or vault access is unavailable, rather than silently skipping key setup.
