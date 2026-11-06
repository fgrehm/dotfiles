# Trust Boundaries

Deliberate trade-offs and rules of thumb for what may talk to what on a
machine running these dotfiles. Read this before granting an untrusted
container, agent thread, or VM access to host resources.

## Containers and agent threads

Anything running as your user (app containers, agent threads, devcontainers
with the home directory mounted) can read everything your user can read,
including:

- **1Password-provisioned SSH key files** in `~/.ssh`. The 1Password recipe downloads configured attachments after confirming desktop-integrated CLI vault access.
- **GCR SSH agent socket** (`$SSH_AUTH_SOCK`). Omarchy enables GCR for SSH authentication and Git commit signing. Processes and containers granted this socket can request authentication and signing operations from keys available to the agent, though they cannot extract private key material from the agent.
- **Screen-time history** (`~/.config/omarchy/screen-time/history.json`). Any process running as the user can read it. The custom tracker is not deployed on the fresh-start setup, but an existing history file is retained.

## Accepted risks (deliberate, reviewed)

- **mise `@latest` on non-Omarchy.** `install-mise-tools.sh` installs the
  repo's `.tool-versions` tool set; on non-Omarchy machines tools with no
  pinned version resolve to `@latest`. This is a rolling policy, accepted for
  dev-tooling convenience. Omarchy-managed tools are not affected.
- **lazy.nvim bootstrap.** `config/nvim/lua/config/lazy.lua` clones
  `folke/lazy.nvim` from the mutable `stable` branch before executing it. The
  58 plugins themselves are SHA-pinned in `lazy-lock.json`; only the
  bootstrap is rolling. Accepted as low risk (high-profile, widely mirrored
  repository) in exchange for not having to maintain a bootstrap pin.
- **`vanta-cli register --secret=` argv.** The enrollment key is passed on
  the command line (visible to local process listing) because vanta-cli has
  no documented env/stdin secret channel. One-time enrollment on a
  single-user workstation; the key input itself is hidden (`read -rs`) and
  the JSON config is assembled with `jq`.

## CI

- Workflow actions are SHA-pinned and run with `permissions: contents: read`.
- The lint container uses the mutable `debian:trixie` tag. Digest-pin it if
  reproducibility ever matters; not currently tracked as a risk since the
  workflow has no secrets and runs untrusted-input-free checks.