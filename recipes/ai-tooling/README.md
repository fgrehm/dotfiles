# ai-tooling

Installs AI tools and deploys their shared configuration (Claude Code, Pi coding agent, shared skills).

## What it does

### Tool installs

- **Claude Code**: installs the CLI binary via the official install script
- **Pi coding agent**: installs globally via npm
- **dot-ai-private**: clones the private overlay repo and runs its `install.sh` (skips gracefully if SSH access is not available)

### Configuration

- `~/.claude/CLAUDE.md`: global instructions for Claude Code
- `~/.claude/statusline.sh`: status line script
- `~/.claude/output-styles/`: custom output styles (`navigator-v1`, `navigator-v2`)
- `~/.claude/settings.json`: deep-merged from a chezmoi-managed base. The merge preserves machine-local keys (model, hooks, plugins, ...) and concatenates permission arrays. See `run_onchange_after_merge-claude-settings.sh.tmpl`.
- `~/.pi/agent/AGENTS.md`: global instructions for the Pi coding agent

### Shared skills

Skills live once at `~/.agents/skills/<name>/` (the canonical cross-client home) and are exposed to each tool via individual symlinks:

- `~/.claude/skills/<name>` -> `~/.agents/skills/<name>`
- `~/.pi/agent/skills/<name>` -> `~/.agents/skills/<name>`

A `run_onchange_after_link-skills.sh.tmpl` script creates these symlinks for every skill in `~/.agents/skills/` and re-runs whenever the skill set changes. It only creates missing symlinks, so anything else you drop into `~/.agents/skills/` (or the per-agent dirs) is left alone. The omarchy skill already lives in `~/.agents/skills/` and coexists.

To vendor a third-party skill from GitHub, use the helper under this recipe:

```sh
recipes/ai-tooling/scripts/vendor-skill.sh https://github.com/owner/repo/tree/main/path/to/skill
```

It pins the skill to a commit SHA and writes the vendored copy under `recipes/ai-tooling/chezmoi/private_dot_agents/skills/<skill>/`.

## Requirements

- wget
- curl
- git
- jq (required by the Claude Code settings merge script)
- npm (required for Pi coding agent)
- Internet access (GitHub releases, npm registry)

## Notes

- dot-ai-private is a private GitHub repo. Cloning requires SSH key forwarding or a configured credential helper. The script exits cleanly if the clone fails so the rest of `chezmoi apply` is not blocked.
