# Trust Boundaries

Deliberate trade-offs and rules of thumb for what may talk to what on a
machine running these dotfiles. Read this before granting an untrusted
container, agent thread, or VM access to host resources.

## Containers and agent threads

Anything running as your user (app containers, agent threads, devcontainers
with the home directory mounted) can read everything your user can read,
including:

- **SSH agent socket** (`$XDG_RUNTIME_DIR/ssh-agent.socket`). The signing key
  is auto-added to the agent on shell startup (`dot_shellrc.d/env.sh` +
  `AddKeysToAgent yes`). A process granted the socket can request signatures
  for anything it holds a public key for. **Do not forward the agent socket
  into untrusted containers.**
- **Cartage socket** (`$XDG_RUNTIME_DIR/cartage.sock`, user daemon, 0600).
  Grants clipboard reading (exfiltration), desktop notifications, and
  `xdg-open` (host UI abuse). **Keep out of untrusted containers.**
- **Screen-time history** (`~/.config/omarchy/screen-time/history.json`).
  Retains full window titles (including private/incognito browsing) for ~95
  days. Any process running as the user can read it. Retention policy is a
  deliberate choice; see the omarchy-plugins recipe for the current state.
- **1Password SSH agent / vault items** reachable through the desktop.

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