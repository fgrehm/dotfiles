# Omarchy Support

Living document tracking the adaptation of this dotfiles repo to [Omarchy](https://omarchy.org/) (Arch-based, Hyprland), alongside the existing Debian support.

## Status

- **Detection** — `isOmarchy` template data is set when `omarchy` is on PATH or `~/.local/share/omarchy` exists. ✅
- **Guard** — `recipes/.recipeignore` skips recipes on Omarchy by default; recipes are re-enabled one at a time as they're adapted. Most are now enabled (see table). ✅
- **Baseline** — `home/` shared files apply cleanly on Omarchy. ✅

## Recipe status

| Recipe | Status | Notes |
|--------|--------|-------|
| git | Enabled | pacman install branch; lazygit/gh externals + completions skipped on Omarchy |
| base | Enabled | per-OS package map (fd-find/fdfind on Debian vs fd on Arch); installs via `omarchy pkg add`; creates `~/.local/bin/fdfind` symlink |
| omarchy | Enabled | Omarchy-only tweaks (incl. starship prompt); ignored on Debian |
| nvim | Enabled | omarchy goodies merged into `config/nvim/` (theme hot-reload, all-themes, transparency, remote_clipboard), guarded by `vim.fn.executable("omarchy")`; ruby-lsp dropped; neo-tree extra added (shows hidden files) |
| mise | Enabled | distro-agnostic, already installed; tools now node/go/ruby/bun (rust dropped); needs `shell` recipe for activation |
| shell | Enabled | bash-only on Omarchy; `useZsh` variable (false on Omarchy) guards zsh install/completions; bashrc preserves omarchy's `default/bash/rc` |
| terminal | Skipped | Debian/KDE-specific (alacritty, tinty). Ghostty handled via the `omarchy` recipe. May be dropped once fully on Omarchy |
| ai-tooling | Enabled | Claude Code already on Omarchy (guard skips install); pi via npm (distro-agnostic); curl fallback for wget-less Omarchy; skills/settings distro-agnostic |
| zellij | Enabled | distro-agnostic (GitHub release binary); shellrc fragment needs the `shell` recipe (enabled on Omarchy) |
| laptop | Enabled | crib CLI (GitHub release) + `~/.config/crib/config.toml`; ttyd/vhs dropped |
| cartage | Enabled | distro-agnostic (GitHub release binary + systemd user service); container-side symlinks skipped on laptop |
| 1password | Enabled | install skipped on Omarchy (preinstalled); SSH-key setup runs on both |
| (others) | Skipped | kde — not yet adapted |

## Follow-ups

- [x] **ai-tooling** — enabled on Omarchy. Claude Code already present (guard skips install); pi via npm (distro-agnostic); `install-claude-code.sh` got a curl fallback since Omarchy lacks wget; skills/settings are distro-agnostic.
- [ ] **Extract shared download helper** — several install scripts call `wget`/`curl` directly (e.g. `install-claude-code.sh`, `install-ollama.sh` before it was dropped). Omarchy lacks `wget` by default. Extract a shared `_download` helper (like the one in `dot-ai-private/install.sh`) into `scripts/` and use it across recipes. Backlog — not now.
- [x] **base** — enabled on Omarchy. Installs via `omarchy pkg add`; package map differs per-OS (`fd-find`/`fdfind` on Debian vs `fd` on Arch); creates a `~/.local/bin/fdfind` symlink so scripts that call `fdfind` keep working.
- [x] **Remove unwanted apps** — `run_once_remove-unwanted-apps.sh` in the `omarchy` recipe removes webapps (Basecamp, Discord, Fizzy, Google Contacts, Zoom, HEY, Google Messages, Google Photos) + obsidian. Webapps share the main browser profile.
- [x] **zellij** — enabled on Omarchy. Distro-agnostic (GitHub release binary); shellrc fragment picked up via the `shell` recipe (enabled).
- [ ] **Browser → brave** — switch default browser to brave (backlog).
- [x] **Install slack** — `run_once_install-slack.sh` in the `omarchy` recipe installs `slack-desktop` via `omarchy pkg aur add` plus `xdg-desktop-portal-wlr` for Wayland screen sharing.
- [ ] **Terminal: ghostty** — installed + set as default via `run_once_install-ghostty.sh` in the `omarchy` recipe. The `terminal` recipe (alacritty/tinty) may be dropped once fully on Omarchy on both laptops.
- [x] **Ghostty window padding → 2px** — omarchy's default is 14px. Override via `~/.config/ghostty/config` + `padding.conf` in the `omarchy` recipe. `padding.conf` is loaded last (as a `config-file`), so it wins over omarchy's 14px. `window-padding-balance = true` distributes leftover space (viewport not divisible by cell size) across all edges instead of stacking it at the bottom. Padding changes only affect new terminals (reload config + open a new window).
- [ ] **Shell: zsh/ohmyzsh** — user would go zsh but could live without it; adapt the `shell` recipe (pacman+curl) if pursued. It's the foundation for other recipes' shellrc fragments.
- [ ] **SSH agent** — stock `ssh-agent.service` enabled via `run_once_enable-ssh-agent.sh` in the `omarchy` recipe; `SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket` set via `environment.d/ssh-agent.conf` (needs re-login to take effect). `AddKeysToAgent yes` already lives in the `shell` recipe (not duplicated). Pending: optionally mask `gpg-agent-ssh.socket` (GnuPG SSH emulation) to prevent it from overriding `SSH_AUTH_SOCK`; verify once per boot.
- [x] **Caps Lock → Ctrl** — done via the `omarchy` recipe (`~/.config/hypr/input.conf`, `kb_options = compose:paus,ctrl:nocaps`).
- [x] **neovim** — TOP PRIORITY: omarchy goodies merged into `config/nvim/` (theme hot-reload, all-themes, transparency, remote_clipboard), guarded by `vim.fn.executable("omarchy")`; ruby-lsp dropped; neo-tree extra added (shows hidden files). `theme.lua` is a dynamic symlink to the Omarchy theme (created by `run_once_after_link-omarchy-theme.sh`, gitignored). Recipe enabled and applied.
- [x] **lazygit** — already installed / managed by Omarchy. Skip the `.chezmoiexternals/lazygit.toml` and its completions on Omarchy so we don't end up with two copies. (Done in recipe; recipe now enabled.)
- [x] **gh** — same as lazygit: already installed / managed by Omarchy. Skip the `.chezmoiexternals/gh.toml` and its completions on Omarchy. (Done in recipe; recipe now enabled.)
- [x] **Completion scripts** — `run_onchange_after_completions-*.sh.tmpl` work on Omarchy: the `shell` recipe (enabled) provides the bash-completion sourcing; `useZsh` gates zsh completions (false on Omarchy).
- [ ] **git-lfs** — not installed on Omarchy; `config.tmpl` sets an LFS filter. Install `git-lfs` (`omarchy pkg add git-lfs`) if LFS repos are used.
- [ ] **SSH commit signing** — `config.tmpl` enables `commit.gpgsign` since the signing key exists. Requires the key loaded in the SSH agent; verify on first commit.
- [x] **Shell prompt: starship conditional newline** — first pass: `~/.config/starship.toml` tracked in the `omarchy` recipe. `add_newline = false` plus a `custom.line_break` module (`require_repo = true`, `format = "\n"`) so a newline appears before `❯` only inside git repos — single-line prompt outside repos, two-line (git info on its own line) inside them. Mirrors the old zsh prompt's `_precmd_prompt_nl`. Validated with `starship prompt` in a repo vs not.
- [ ] **Shell prompt: Nerd Font git icons (backlog)** — replace the plain `git_status` symbols with monochrome Nerd Font glyphs (e.g. `\uf044` pencil for modified, `\uf128` question for untracked, `\uf01c` inbox for stashed, `\uf0aa`/`\uf0ab` arrows for ahead/behind). All verified present in JetBrainsMono Nerd Font; avoid Unicode color emoji (poor rendering in the font).

## Notes

- **Debian is still a supported bare-metal target** — one laptop still runs Debian 13. The ultimate goal is to migrate fully to Omarchy and drop Debian as bare-metal, keeping it for devcontainers/Codespaces. Recipes are adapted to Omarchy one at a time; Debian support is kept alongside until the transition is complete.
- **1password is preinstalled on Omarchy** — the install script is skipped (via `.chezmoiignore`), but the SSH-key setup still runs on Omarchy.
- Omarchy uses `pacman` (via `omarchy pkg`), not `apt`. Install scripts that call `apt-get` need a pacman branch guarded by `{{ if .isOmarchy }}`.
- Omarchy manages its own desktop/WM config (hypr, waybar, walker, terminals, mako) — recipes like `kde`/`terminal` are likely candidates to skip or rework.
- **Config philosophy:** only track a config in the repo when there's a need to customize it. Otherwise let omarchy manage it. Ghostty is the one exception: we track `~/.config/ghostty/config` + `padding.conf` to override the window padding to 2px (omarchy's default is 14px).

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
- **`omarchy` commands handle sudo internally** — `omarchy pkg add`, `omarchy install`, etc. declare `requires-sudo=true` and call `sudo` themselves. Don't prefix `$SUDO` (it breaks: sudo can't find `omarchy` in its restricted PATH). Call `omarchy ...` directly.
- **lazygit/gh are already installed/managed by omarchy** — skip their `.chezmoiexternals` and completions on omarchy to avoid duplicates.
- **`run_once_` vs `run_once_after_`** — use `run_once_` (before file deployment) for scripts that don't depend on deployed files; `run_once_after_` only when a script needs files in place first.
- **Omarchy's nvim `theme.lua` is a dynamic symlink** to `~/.config/omarchy/current/theme/neovim.lua` (which itself points to the current theme's `neovim.lua`). It follows `omarchy theme set`. Don't track it as a static file; create the symlink via a run_once script. A relative symlink won't work because the repo's `config/nvim` is symlinked into `~/.config/nvim` (relative targets resolve against the repo path).
- **LazyVim has no file explorer by default** — it's opt-in via extras (`neo-tree` or `mini-files`). The repo's Debian config used only the snacks file picker; omarchy added neo-tree. To show hidden files in neo-tree by default: `filesystem.filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = false }`.
- **Template directives require `.sh.tmpl`** — a `.sh` script with `# {{ if ... }}` treats the directives as inert comments (e.g. `SUDO` never gets set). For omarchy-only scripts, prefer `id -u` over template conditionals to avoid the `.tmpl` requirement.
- **`useZsh` template variable** — `useZsh = {{ not $isOmarchy }}` (true on Debian, false on Omarchy). Decouples zsh from omarchy: guards zsh/ohmyzsh install, default-shell setup, `.zshrc` deploy, and zsh completion generation. Requires re-running `chezmoi init` to re-render the config.
- **Omarchy's `~/.bashrc` sources `~/.local/share/omarchy/default/bash/rc`** (envs, shell, aliases, functions, init, inputrc). The shell recipe's `dot_bashrc` must preserve this on omarchy (it's now a template that sources omarchy's rc + `~/.shellrc` on omarchy, the Debian bashrc elsewhere).
- **`omarchy-webapp-remove` takes multiple names and restarts the app launcher once** — pass all apps in one call to avoid systemd start-limit on rapid restarts. Webapps share the main browser profile (launched via `browser --app=<url>`).
- **Bash git-alias completion** — use git's `__git_complete <alias> _git_<subcommand>` (not `complete -F _git_<subcommand>`, which breaks because the functions expect `$1=git`). Source the git completion file first (it's lazy-loaded), then wire each alias. This restores the autocomplete that zsh's `compdef` gave.
- **Ghostty `config-file` override** — `config-file` entries are processed *after* the file that declares them, in order, so the **last** `config-file` wins. To override omarchy's shipped ghostty config (read-only at `~/.local/share/omarchy/config/ghostty/config`), track a `~/.config/ghostty/config` that includes it first, then a `padding.conf` loaded last. Verified empirically: a `font-size` set in the last config-file overrides omarchy's. `+show-config` does not print `window-padding-*`, so verify overrides with a value it does print (e.g. `font-size`). Padding changes only affect new terminals.
