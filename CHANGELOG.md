# Changelog

## 2026-03-26

- **ai-tooling recipe**: renamed from `coding-agents`, added install script for ollama (skipped in containers)

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
