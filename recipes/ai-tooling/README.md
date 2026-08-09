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
- `~/.pi/agent/extensions/venice-provider.ts`: Venice.ai model provider extension

### Shared skills

Skills live once at `~/.ai/agent-skills/<name>/` and are exposed to both tools via whole-directory symlinks:

- `~/.claude/skills` -> `~/.ai/agent-skills`
- `~/.pi/agent/skills` -> `~/.ai/agent-skills`

Drop additional per-machine or experimental skills directly under `~/.ai/agent-skills/`. chezmoi only manages the skills it placed there; anything extra you add by hand is left alone.

To vendor a third-party skill from GitHub, use the helper under this recipe:

```sh
recipes/ai-tooling/scripts/vendor-skill.sh https://github.com/owner/repo/tree/main/path/to/skill
```

It pins the skill to a commit SHA and writes the vendored copy under `recipes/ai-tooling/chezmoi/private_dot_ai/agent-skills/<skill>/`.

#### Limitation: whole-dir symlinks leak local skills into the tool dirs

Because `~/.claude/skills` and `~/.pi/agent/skills` are whole-directory symlinks, any skill you install locally for an experiment lands under `~/.ai/agent-skills/` (the only place both tools can see it) and is visible to every other tool through the same symlink. There is no "local scratch" dir that only one tool sees.

If you want stricter isolation, the alternative is to drop the whole-dir symlinks and instead symlink each skill individually:

- `~/.claude/skills/<name>` -> `~/.ai/agent-skills/<name>`
- `~/.pi/agent/skills/<name>` -> `~/.ai/agent-skills/<name>`

That was the previous shape (pre-fold `dot-ai/install.sh`): real directories on both sides, one symlink per managed skill, local/experimental skills sitting as real subdirs next to them without touching the other tool. The tradeoff is 21 chezmoi symlink entries per tool instead of one, and you have to remember to symlink new skills into both trees.

## Requirements

- wget
- curl
- git
- jq (required by the Claude Code settings merge script)
- npm (required for Pi coding agent)
- Internet access (GitHub releases, npm registry)

## Notes

- dot-ai-private is a private GitHub repo. Cloning requires SSH key forwarding or a configured credential helper. The script exits cleanly if the clone fails so the rest of `chezmoi apply` is not blocked.
