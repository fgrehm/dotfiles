# Changelog

## 2026-03-27

### Added

- **chezmoiexternals**: replaced binary install scripts with `.chezmoiexternals/*.toml` for cartage, zellij, clotilde, dotmem, ttyd, vhs -- pinned versions, no more shell download logic
- **ai-tooling recipe**: renamed from `coding-agents`, added ollama (skipped in containers via `.chezmoiignore`)

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
