# Omarchy Support

Living document tracking the adaptation of this dotfiles repo to [Omarchy](https://omarchy.org/) (Arch-based, Hyprland), alongside the existing Debian support.

## Status

- **Detection** — `isOmarchy` template data is set when `omarchy` is on PATH or `~/.local/share/omarchy` exists. ✅
- **Guard** — `recipes/.recipeignore` skips all recipes on Omarchy by default; recipes are re-enabled one at a time as they're adapted. ✅
- **Baseline** — `home/` shared files apply cleanly on Omarchy. ✅

## Recipe status

| Recipe | Status | Notes |
|--------|--------|-------|
| git | Enabled | pacman install branch; lazygit/gh externals + completions skipped on Omarchy |
| omarchy | Enabled | Omarchy-only tweaks; ignored on Debian |
| nvim | Enabled | omarchy goodies merged into `config/nvim/` (theme hot-reload, all-themes, transparency, remote_clipboard), guarded by `vim.fn.executable("omarchy")`; ruby-lsp dropped; neo-tree extra added (shows hidden files) |
| mise | Enabled | distro-agnostic, already installed; tools now node/go/ruby/bun (rust dropped); needs `shell` recipe for activation |
| shell | Enabled | bash-only on Omarchy; `useZsh` variable (false on Omarchy) guards zsh install/completions; bashrc preserves omarchy's `default/bash/rc` |
| terminal | Skipped | Debian/KDE-specific (alacritty, tinty). Ghostty handled via the `omarchy` recipe. May be dropped once fully on Omarchy |
| ai-tooling | Skipped | NEXT UP: high value (Claude Code, pi, ollama, skills). Claude Code already on Omarchy; config largely distro-agnostic; needs install-script adaptation |
| zellij | Skipped | low risk; distro-agnostic; needs `shell` recipe for shellrc fragment. PUNTED — user may skip zellij in favor of tmux or herdr.dev |
| (others) | Skipped | not yet adapted |

## Follow-ups

- [ ] **ai-tooling** — NEXT UP: high value (Claude Code, pi, ollama, skills). Claude Code already on Omarchy; config (skills, settings) largely distro-agnostic; needs install-script adaptation (Claude Code present, pi via npm, ollama).
- [ ] **base** — low priority on Omarchy (jq/unzip/gpg present; wget/fd-find differ).
- [ ] **Remove unwanted apps** — `run_once_remove-unwanted-apps.sh` in the `omarchy` recipe removes webapps (Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos) + obsidian. Webapps share the main browser profile.
- [ ] **zellij** — PUNTED: user may skip zellij and stick with tmux or move to herdr.dev. Revisit later.
- [ ] **Browser → brave** — switch default browser to brave (backlog).
- [ ] **Install slack** — later (deferred).
- [ ] **Terminal: ghostty** — installed + set as default via `run_once_install-ghostty.sh` in the `omarchy` recipe. The `terminal` recipe (alacritty/tinty) may be dropped once fully on Omarchy on both laptops.
- [ ] **Shell: zsh/ohmyzsh** — user would go zsh but could live without it; adapt the `shell` recipe (pacman+curl) if pursued. It's the foundation for other recipes' shellrc fragments.
- [ ] **SSH agent** — stock `ssh-agent.service` enabled via `run_once_enable-ssh-agent.sh` in the `omarchy` recipe; `SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket` set via `environment.d/ssh-agent.conf` (needs re-login to take effect). `AddKeysToAgent yes` already lives in the `shell` recipe (not duplicated). Pending: optionally mask `gpg-agent-ssh.socket` (GnuPG SSH emulation) to prevent it from overriding `SSH_AUTH_SOCK`; verify once per boot.
- [x] **Caps Lock → Ctrl** — done via the `omarchy` recipe (`~/.config/hypr/input.conf`, `kb_options = compose:paus,ctrl:nocaps`).
- [x] **neovim** — TOP PRIORITY: omarchy goodies merged into `config/nvim/` (theme hot-reload, all-themes, transparency, remote_clipboard), guarded by `vim.fn.executable("omarchy")`; ruby-lsp dropped; neo-tree extra added (shows hidden files). `theme.lua` is a dynamic symlink to the Omarchy theme (created by `run_once_after_link-omarchy-theme.sh`, gitignored). Recipe enabled and applied.
- [ ] **lazygit** — already installed / managed by Omarchy (unknown how). Skip the `.chezmoiexternals/lazygit.toml` and its completions on Omarchy so we don't end up with two copies. (Done in recipe; recipe now enabled.)
- [ ] **gh** — same as lazygit: already installed / managed by Omarchy. Skip the `.chezmoiexternals/gh.toml` and its completions on Omarchy. (Done in recipe; recipe now enabled.)
- [ ] **Completion scripts** — will `run_onchange_after_completions-*.sh.tmpl` work without the `shell` recipe? They write to `~/.local/share/bash-completion/completions` and `~/.zsh/completions`, but whether those get sourced depends on the shell setup. Likely the next focus after the caps-lock→ctrl remap.
- [ ] **git-lfs** — not installed on Omarchy; `config.tmpl` sets an LFS filter. Install `git-lfs` (`omarchy pkg add git-lfs`) if LFS repos are used.
- [ ] **SSH commit signing** — `config.tmpl` enables `commit.gpgsign` since the signing key exists. Requires the key loaded in the SSH agent; verify on first commit.

## Notes

- Omarchy uses `pacman` (via `omarchy pkg`), not `apt`. Install scripts that call `apt-get` need a pacman branch guarded by `{{ if .isOmarchy }}`.
- Omarchy manages its own desktop/WM config (hypr, waybar, walker, terminals, mako) — recipes like `kde`/`terminal` are likely candidates to skip or rework.
- **Config philosophy:** only track a config in the repo when there's a need to customize it. Otherwise let omarchy manage it (e.g. ghostty config is omarchy's default; we only handle install + default terminal).

## Learnings

- **Omarchy config locations** — `~/.config/hypr/` (and other `~/.config/`) is user config, safe to edit. `~/.local/share/omarchy/` is read-only (git-managed, lost on `omarchy update`). `omarchy refresh <app>` resets a config to defaults (backs up first).
- **Base tracked configs on omarchy's shipped defaults**, not the live file. The live file may contain stale/experimental tweaks. Compare against `~/.local/share/omarchy/config/<app>/...` and apply only the intended change.
- **Validate Hyprland changes** with `hyprctl reload` then `hyprctl configerrors` (must be clean).
- **Caps Lock → Ctrl** is `kb_options = ctrl:nocaps` in the hypr `input` block. Omarchy's default `compose:caps` conflicts with `ctrl:nocaps` (both remap caps lock), so move compose to another key (e.g. `compose:paus,ctrl:nocaps`).
- **openssh ships a stock `ssh-agent.service` + `ssh-agent.socket`** user unit — enable it rather than writing a custom one. Point `SSH_AUTH_SOCK` at `$XDG_RUNTIME_DIR/ssh-agent.socket`.
- **`environment.d`** (`~/.config/environment.d/*.conf`) sets env vars for the systemd user manager and propagates to the Hyprland session — but only read at systemd user manager startup, so it needs a re-login to take effect.
- **`gpg-agent-ssh.socket`** (GnuPG SSH emulation) is active by default and can set `SSH_AUTH_SOCK` via `ExecStartPost`, conflicting with a separate ssh-agent. Mask it if it hijacks `SSH_AUTH_SOCK`.
- **`AddKeysToAgent yes`** in `~/.ssh/config` auto-adds keys to the agent on first use (no manual `ssh-add`).
- **omarchy has no `wget` by default** — use `curl` fallback in scripts (see `install.sh` `_download`).
- **lazygit/gh are already installed/managed by omarchy** — skip their `.chezmoiexternals` and completions on omarchy to avoid duplicates.
- **`run_once_` vs `run_once_after_`** — use `run_once_` (before file deployment) for scripts that don't depend on deployed files; `run_once_after_` only when a script needs files in place first.
- **Omarchy's nvim `theme.lua` is a dynamic symlink** to `~/.config/omarchy/current/theme/neovim.lua` (which itself points to the current theme's `neovim.lua`). It follows `omarchy theme set`. Don't track it as a static file; create the symlink via a run_once script. A relative symlink won't work because the repo's `config/nvim` is symlinked into `~/.config/nvim` (relative targets resolve against the repo path).
- **LazyVim has no file explorer by default** — it's opt-in via extras (`neo-tree` or `mini-files`). The repo's Debian config used only the snacks file picker; omarchy added neo-tree. To show hidden files in neo-tree by default: `filesystem.filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false }`.
- **Template directives require `.sh.tmpl`** — a `.sh` script with `# {{ if ... }}` treats the directives as inert comments (e.g. `SUDO` never gets set). For omarchy-only scripts, prefer `id -u` over template conditionals to avoid the `.tmpl` requirement.
- **`useZsh` template variable** — `useZsh = {{ not $isOmarchy }}` (true on Debian, false on Omarchy). Decouples zsh from omarchy: guards zsh/ohmyzsh install, default-shell setup, `.zshrc` deploy, and zsh completion generation. Requires re-running `chezmoi init` to re-render the config.
- **Omarchy's `~/.bashrc` sources `~/.local/share/omarchy/default/bash/rc`** (envs, shell, aliases, functions, init, inputrc). The shell recipe's `dot_bashrc` must preserve this on omarchy (it's now a template that sources omarchy's rc + `~/.shellrc` on omarchy, the Debian bashrc elsewhere).
- **`omarchy-webapp-remove` takes multiple names and restarts the app launcher once** — pass all apps in one call to avoid systemd start-limit on rapid restarts. Webapps share the main browser profile (launched via `browser --app=<url>`).
- **Bash git-alias completion** — use git's `__git_complete <alias> _git_<subcommand>` (not `complete -F _git_<subcommand>`, which breaks because the functions expect `$1=git`). Source the git completion file first (it's lazy-loaded), then wire each alias. This restores the autocomplete that zsh's `compdef` gave.
