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
| (others) | Skipped | not yet adapted |

## Follow-ups

- [ ] **Caps Lock → Ctrl** — done via the `omarchy` recipe (`~/.config/hypr/input.conf`, `kb_options = compose:paus,ctrl:nocaps`).
- [ ] **neovim** — TOP PRIORITY: merge the existing neovim setup with Omarchy's goodies. Review the `nvim` recipe and reconcile with what Omarchy ships/manages.
- [ ] **lazygit** — already installed / managed by Omarchy (unknown how). Skip the `.chezmoiexternals/lazygit.toml` and its completions on Omarchy so we don't end up with two copies. (Done in recipe; recipe now enabled.)
- [ ] **gh** — same as lazygit: already installed / managed by Omarchy. Skip the `.chezmoiexternals/gh.toml` and its completions on Omarchy. (Done in recipe; recipe now enabled.)
- [ ] **Completion scripts** — will `run_onchange_after_completions-*.sh.tmpl` work without the `shell` recipe? They write to `~/.local/share/bash-completion/completions` and `~/.zsh/completions`, but whether those get sourced depends on the shell setup. Likely the next focus after the caps-lock→ctrl remap.
- [ ] **git-lfs** — not installed on Omarchy; `config.tmpl` sets an LFS filter. Install `git-lfs` (`omarchy pkg add git-lfs`) if LFS repos are used.
- [ ] **SSH commit signing** — `config.tmpl` enables `commit.gpgsign` since the signing key exists. Requires the key loaded in the SSH agent; verify on first commit.

## Notes

- Omarchy uses `pacman` (via `omarchy pkg`), not `apt`. Install scripts that call `apt-get` need a pacman branch guarded by `{{ if .isOmarchy }}`.
- Omarchy manages its own desktop/WM config (hypr, waybar, walker, terminals, mako) — recipes like `kde`/`terminal` are likely candidates to skip or rework.
