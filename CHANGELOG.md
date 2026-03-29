# Changelog

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
