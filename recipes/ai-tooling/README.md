# ai-tooling

Installs AI tools and their supporting utilities.

## What it does

- **Claude Code**: installs the CLI binary via the official install script
- **Pi coding agent**: installs globally via npm
- **ollama**: installs via official script (skipped in containers, see `.chezmoiignore`)
- **dot-ai**: clones [dot-ai](https://github.com/fgrehm/dot-ai) to `~/.local/share/dot-ai`
  and runs its `install.sh` (skills, settings, output styles for Claude Code and Pi)
- **dot-ai-private**: clones private overlay repo (skips gracefully if not accessible)
- **dotmem**: installs [dotmem](https://github.com/fgrehm/dotmem) binary to `~/.local/bin`
  (centralized Claude Code memory management)
- **Clotilde**: installs [clotilde](https://github.com/fgrehm/clotilde) binary to `~/.local/bin`
  (Claude Code session manager)

## Requirements

- wget
- curl
- git
- jq (required by dot-ai's install.sh for settings merge)
- npm (required for Pi coding agent)
- Internet access (GitHub releases, npm registry)

## Notes

- ollama is skipped in containers via `.chezmoiignore` (no systemd for the service)
- dot-ai-private is a private GitHub repo. Cloning requires SSH key forwarding or a
  configured credential helper. The script exits cleanly if the clone fails so the
  rest of `chezmoi apply` is not blocked.