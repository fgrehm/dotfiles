# dot-ai

Installs [dot-ai](https://github.com/fgrehm/dot-ai) (public Claude Code skills + settings) and
dot-ai-private (private overlay with additional skills).

## What it does

- Clones dot-ai to `~/.local/share/dot-ai` and runs its `install.sh`, which:
  - Links `~/.claude/CLAUDE.md` → dot-ai's CLAUDE.md
  - Merges `~/.claude/settings.json` with dot-ai's base settings
  - Links `~/.claude/output-styles` → dot-ai's output-styles
  - Symlinks per-skill directories into `~/.claude/skills/`
  - Same for `~/.pi/agent/`
- Clones dot-ai-private to `~/.local/share/dot-ai-private` and runs its `install.sh`
  (skips gracefully if the repo is not accessible, e.g. no SSH keys in container)

## Requirements

- git
- jq (required by install.sh for settings merge)

## Notes

dot-ai-private is a private GitHub repo. Cloning requires SSH key forwarding or a
configured credential helper. The script exits cleanly if the clone fails so the
rest of `chezmoi apply` is not blocked.

To update skills after install: `~/.local/share/dot-ai/install.sh`
