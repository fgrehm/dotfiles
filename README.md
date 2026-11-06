# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). The bare-metal/laptop target is [Omarchy](https://omarchy.org/) (Arch-based, Hyprland); Debian-based images are supported for devcontainers, Codespaces, and CI.

## Supported Platforms

- **Omarchy** (Arch-based, Hyprland) — the bare-metal/laptop target
- **Debian-based containers and VMs** (Debian 13, Ubuntu, etc.) — devcontainers, Codespaces, CI, and other non-Omarchy environments

Omarchy is the only bare-metal target. The `apt` branches in install scripts exist for the container path; on Omarchy the equivalent steps go through `omarchy pkg add` / `pacman`.

## Quick Start

```bash
git clone https://github.com/fgrehm/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
./install.sh
```

## How It Works

Dotfiles are organized into modular **recipes** under `recipes/`. Each recipe groups related chezmoi files (configs, install scripts, shell fragments) for a single tool. chezmoi-recipes overlays them into a generated `compiled-home/` directory, then chezmoi applies as normal.

Agent configuration is maintained separately in [`dotagents`](https://github.com/fgrehm/dotagents), a plain-files repo with its own Bash installer; it is not part of this chezmoi overlay. After the first successful `chezmoi apply`, the `dotagents` recipe clones it and delegates to that installer. It uses `/data/projects/dotagents` when `/data/projects` is a mount point, otherwise `~/Projects/oss/dotagents` when `~/Projects` exists, otherwise `~/.local/share/dotagents`; SSH clone failure falls back to HTTPS.

```
home/                         shared chezmoi source files
recipes/
  <recipe-name>/
    README.md                 recipe documentation
    chezmoi/                  chezmoi source fragment for this recipe
      .chezmoiscripts/
      dot_*/
      private_dot_config/
compiled-home/                generated (gitignored), fed to chezmoi
```

## Recipes

See [`recipes/`](recipes/) for the full list. Each recipe has its own README.

## Fresh Machine Setup

On a fresh Omarchy laptop, install and sign in to 1Password before running `install.sh`:

1. In the Omarchy menu, choose **Install > Service > 1Password**. This installs the desktop app and CLI (`op`).
2. Open 1Password and sign in to your account.
3. In 1Password, enable **Settings > Developer > Integrate with 1Password CLI**.
4. From a new terminal, confirm `op vault list` works. `op whoami` may report that the account is not signed in even when desktop integration is working.
5. Run `./install.sh`. On Omarchy, it runs `scripts/preflight-1password.sh` before bootstrapping chezmoi and stops if `op` is missing or cannot access vaults.

The first `chezmoi apply` retrieves configured SSH keys from your 1Password vault and enables Omarchy's GCR SSH agent. Log out and back in for `SSH_AUTH_SOCK` to reach the session. Git enables SSH commit signing when `~/.ssh/id_ed25519-sign.pub` is present. The same agent socket can be forwarded into containers; processes with access to it can request signatures as well as SSH authentication. If other recipes need the downloaded keys (for example, to access private repositories), run `chezmoi apply` again after the keys are present.

## Development

Run checks in CI or in an isolated environment with the tools from [`.tool-versions`](.tool-versions).

```bash
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects the environment via `/.dockerenv`, env vars, `omarchy` on PATH, etc. Template data available: `.name`, `.email`, `.isContainer`, `.isOmarchy`, `.hasNvidiaGPU`, `.hasToolchain`, `.hydratesHome`, `.onepasswordSshVault`, `.onepasswordSshItem`.

## Contributions

This is open source **personal software**: I build it primarily for myself and share the source in case it's useful to others. [Discussions](https://github.com/fgrehm/dotfiles/discussions) are open for questions, ideas, feedback, and sharing what you've built with it.

Issues and pull requests are reserved for my own tracking and development workflow. Feel free to fork and modify the project under its license, or bring ideas and fixes to Discussions. Depending on interest, I'm very open to evolving it into a more traditional open source project with broader contributions.

## License

MIT