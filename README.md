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

Agent configuration is maintained separately in [`dotagents`](https://github.com/fgrehm/dotagents), a plain-files repo with its own Bash installer; it is not part of this chezmoi overlay. After the first successful `chezmoi apply`, the `dotagents` recipe clones it and delegates to that installer. It prefers `/data/projects/oss/dotagents`, then `~/Projects/oss/dotagents`, then `~/.local/share/dotagents`; SSH clone failure falls back to HTTPS.

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

On a new laptop, `chezmoi apply` needs to run twice:

1. **First apply** -- downloads SSH keys from your 1Password vault (on Omarchy, 1Password is preinstalled so only the key download runs). Other recipes that need SSH (e.g. private repos) will skip gracefully on this run.
2. **Second apply** -- SSH keys are now on disk; any recipe that skipped will retry and complete normally.

## Development

Run checks in CI or in an isolated environment with the tools from [`.tool-versions`](.tool-versions).

```bash
make check      # lint shell scripts (shfmt + shellcheck)
```

### Environment Detection

`.chezmoi.toml.tmpl` auto-detects the environment via `/.dockerenv`, env vars, `omarchy` on PATH, etc. Template data available: `.name`, `.email`, `.isContainer`, `.isOmarchy`, `.hasNvidiaGPU`, `.onepasswordSshVault`, `.onepasswordSshItem`.

## Contributions

This is open source **personal software**: I build it primarily for myself and share the source in case it's useful to others. [Discussions](https://github.com/fgrehm/dotfiles/discussions) are open for questions, ideas, feedback, and sharing what you've built with it.

Issues and pull requests are reserved for my own tracking and development workflow. Feel free to fork and modify the project under its license, or bring ideas and fixes to Discussions. Depending on interest, I'm very open to evolving it into a more traditional open source project with broader contributions.

## License

MIT