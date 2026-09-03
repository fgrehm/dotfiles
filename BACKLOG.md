# Backlog

Open items not yet done. Checked-off migration work that used to live in `OMARCHY.md` was dropped when Omarchy became the sole bare-metal target.

## Omarchy

- **Omarchy plugin QML linting.** Add a local-only `qmllint`/QML validation hook for `config/omarchy-plugins/`. First determine the correct import configuration for Omarchy's `qs.Commons` and `qs.Ui` modules; standalone `qmllint` currently exits non-zero on `Panel.qml` without resolving those modules.
- **US-intl cedilla and toolbar indicator.** US and US International layouts are active via Hyprland, with no custom toolbar indicator. The `~/.XCompose` override now maps `dead_acute + c` to `ç`, but still needs testing after deployment and application restart. Revisit the indicator separately if desired.
- **Cedilla fix for US-intl dead keys on GTK.** The old `kde` recipe patched the GTK cedilla input module (added `en` to its locale filter) and the X11 Compose file so `dead_acute + c` produces c-cedilla, not c-acute, under `en_US.UTF-8` with US-intl dead keys. The Compose portion is now tracked in `recipes/omarchy/chezmoi/private_XCompose`; verify whether the GTK-specific patch is still needed.
- **MX Keys brightness controls for external monitor.** Logitech MX Keys exposes brightness buttons as HID++ controls that do not reach `wev` or `keyd monitor` on Wayland. Workaround if needed: `Fn + brightness down/up` emits `F1/F2`, which can be bound to `omarchy-brightness-display 5%-` / `omarchy-brightness-display +5%`; those bindings are intentionally not tracked while investigating a proper direct-key solution. Revisit Solaar diversion/rules; Omarchy issues [#1901](https://github.com/basecamp/omarchy/issues/1901) and [#2509](https://github.com/basecamp/omarchy/issues/2509) document the broader external-monitor/DDC limitation.
- **Starship Nerd Font git-status icons.** Replace the plain `git_status` symbols in `~/.config/starship.toml` with monochrome Nerd Font glyphs (e.g. `\uf044` pencil for modified, `\uf128` question for untracked, `\uf01c` inbox for stashed, `\uf0aa`/`\uf0ab` arrows for ahead/behind). All verified present in JetBrainsMono Nerd Font; avoid Unicode color emoji (poor rendering in the font).
- **zsh/ohmyzsh on Omarchy.** Not pursued; omarchy's default is bash. If taken up, adapt the `shell` recipe (pacman install + curl for ohmyzsh, since omarchy has no wget). It's the foundation for other recipes' shellrc fragments.
- **Mask `gpg-agent-ssh.socket` if it hijacks `SSH_AUTH_SOCK`.** The stock `ssh-agent.service` is enabled by the `omarchy` recipe, but `gpg-agent-ssh.socket` (GnuPG SSH emulation) is active by default and can override `SSH_AUTH_SOCK` via `ExecStartPost`. Mask it if it conflicts; verify once per boot.
- **omasnap integration (currently live-only).** Trying out [omasnap](https://github.com/tobi/omasnap) as the screenshot tool. The PRINT binding (`unbind = , PRINT` + `bindd = , PRINT, Screenshot, exec, omasnap`) lives in `~/.config/hypr/local.conf` (machine-local, untracked). If it sticks: promote the binding into a tracked recipe, and consider also adding the README's `layer_rule` for the `^omasnap$` namespace (`no_anim = true`, belongs in `windowrules.conf`) and tracking the install (`install-omarchy` script + `.chezmoiexternals` is not a fit since it builds from source -- likely a `run_onchange_after_` install script gated by `command -v omasnap`). Drop the `local.conf` override once the binding is tracked.

## Cross-recipe

- **Avoid managing `~/.ssh` as a directory.**
- **Protect redirected agent skill directories.** `dot-ai-private/install.sh` removes a symlink at `~/.claude/skills` or `~/.pi/agent/skills` before recreating it locally. Fix upstream to follow an existing redirected directory instead of removing the symlink. `recipes/shell/chezmoi/private_dot_ssh/create_private_config` has the same managed-parent-directory risk as the former `~/.claude` payload. Move it to a `run_onchange_after_` script that writes `~/.ssh/config` only when absent, preserving the current `create_` semantics.
- **Shared `_download` helper in `scripts/`.** Several install scripts call `wget`/`curl` directly. Omarchy has no `wget` by default. Extract a shared `_download` helper (like the one in `install.sh`) into `scripts/` and use it across recipes instead of ad-hoc wget/curl.

## git

- **git-lfs** is not installed on Omarchy; `config.tmpl` sets an LFS filter. Install `git-lfs` (`omarchy pkg add git-lfs`) if LFS repos are used.
- **SSH commit signing** -- `config.tmpl` enables `commit.gpgsign` since the signing key exists. Requires the key loaded in the SSH agent; verify on first commit.

## terminal / zellij

- **Ctrl+Shift+PgUp/PgDown not working for zellij inside ghostty.** Used to work; broken now. Investigate whether a ghostty keybind change or a zellij update swallowed it.