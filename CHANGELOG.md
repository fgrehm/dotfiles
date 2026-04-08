# Changelog

## 2026-04-07

### Added

- **terminal recipe**: install alacritty via apt, deploy config (CaskaydiaMono Nerd Font, keybindings, cursor fix), set as default terminal
- **kde recipe**: configure keyboard layouts (US + US-intl dead keys), remap caps lock to ctrl, Super+Space layout switch, fix cedilla input for en_US locale
- **ci**: add `make check` (shfmt + shellcheck) lint step to CI workflow
- **devcontainer**: add shfmt and shellcheck to `.tool-versions`, Dockerfile now reads tool versions from `.tool-versions` (single source of truth)

### Fixed

- **cartage recipe**: rename `enable-cartage.sh` to `.sh.tmpl` so template guards (`# {{ if .isContainer }}`) are actually evaluated by chezmoi; without `.tmpl`, the guard was inert and the script always skipped on laptops
- **mise recipe**: same `.sh` -> `.sh.tmpl` fix for `install-mise-tools.sh`; mise tool install was always skipped on laptops
- **base recipe**: fix shfmt formatting (alignment whitespace)
- **shellcheck**: set `--severity=warning` in Makefile to skip intentional SC2086 on unquoted `$SUDO`

### Changed

- **CLAUDE.md**: document KDE Plasma 6 as target desktop environment; add rule about `.sh.tmpl` extension requirement for scripts with template directives
- **copilot-instructions.md**: add review rule to flag `.sh` files containing template directives as bugs
- **updates**: dotmem (0.3.0), nvim (0.12.1), worktrunk (0.34.2)

## 2026-04-02

### Added

- **base recipe**: new recipe that installs foundational apt packages (jq, wget, gnupg) with a `000-` prefix so it runs before all other scripts

### Changed

- **install scripts**: all `run_once_` install scripts now hard-fail (`set -eo pipefail` at top level, no graceful `_install()` wrapper) so `chezmoi apply` retries automatically on failure without needing `chezmoi state delete`
- **ci**: bump `actions/checkout` v4→v6, `actions/cache` v4→v5 to target Node.js 24 natively

## 2026-04-01

### Added

- **security**: pin hardcoded sha256 checksums for all chezmoiexternals; chezmoi now verifies each download before extracting
- **security**: verify nvim tarball sha256 before extracting; checksum mismatch is fatal
- **platform**: restrict to amd64 only; `run_once_before_000-check-arch.sh` fails fast on non-x86_64, arch conditionals removed from all externals

## 2026-03-31

### Added

- **1password recipe**: install 1Password desktop app and CLI from official apt repo, bootstrap SSH keys from vault/item after install (skipped in containers, vault/item prompted at init time)

### Fixed

- **check-versions script**: exclude `compiled-home/` from directory scan to prevent checking pinned versions twice (once from source, once from generated overlay)
- **ai-tooling recipe**: retry dot-ai-private clone after SSH key becomes available

### Changed

- **delta**: update to v0.19.2
- **neovim**: update to v0.12.0
- **clotilde**: update to v0.11.0
- **nvim recipe**: fix installer lint issue
- **docs**: document two-apply bootstrap flow for fresh machines

## 2026-03-29

### Changed

- **ai-tooling recipe**: disable ollama autostart after install, start on demand with `systemctl start ollama`
- **git recipe**: SSH URL rewrite (`insteadOf`) now conditional on SSH key being present, HTTPS by default
- **nvim recipe**: show plugin sync output on failure instead of swallowing it, add 2 minute timeout
- **install.sh**: detect when run from within the repo and skip cloning

## 2026-03-27

### Added

- **git recipe**: added gh CLI via chezmoiexternals (pinned to v2.89.0) and `gh-pr-review` extension (pinned to v1.6.2)
- **chezmoiexternals**: replaced binary install scripts with `.chezmoiexternals/*.toml` for cartage, zellij, clotilde, dotmem, ttyd, vhs -- pinned versions, no more shell download logic
- **ai-tooling recipe**: renamed from `coding-agents`, added ollama (skipped in containers via `.chezmoiignore`)
- **check-versions**: `make check-versions` scans `.chezmoiexternals/*.toml` and shell scripts for pinned versions, compares against GitHub latest releases. Uses `gh` CLI auth, `GITHUB_TOKEN`, or unauthenticated curl

### Fixed

- **neovim**: pinned to v0.11.6, fixed hardcoded `x86_64` arch (now detects at runtime)
- **diffnav**: scoped as pager to `git diff` and `git show` only, no longer overrides `git log`
- **chezmoiexternals modeline**: vim modeline must go at bottom of `.toml` files -- `{{- -}}` trim markers break TOML parsing if it's first
- **clotilde completions**: hash now points to `clotilde.toml` external instead of deleted install script

### Changed

- **devcontainer**: chezmoi-recipes pinned to v0.5.0
- **CLAUDE.md / copilot-instructions.md**: updated chezmoiexternals patterns, version pinning convention, modeline placement rule


## 2026-03-23

### Added

- **coding-agents recipe**: consolidated `dot-ai` and `clotilde` into a single recipe, added install scripts for Claude Code, Pi coding agent, and dotmem
- **mise global config**: deploy `~/.config/mise/config.toml` with node, go, ruby, rust (skipped in containers)
- `run_onchange_after` script to run `mise install` when config changes
- `.github/copilot-instructions.md` for PR reviews
- Script ordering, conditional file skipping, and config-triggered re-run docs in CLAUDE.md

### Fixed

- Added `pipefail` to all install scripts with wget pipelines
- Fixed e2e test header comments to reference `make test-e2e`
