# ai-tooling

Deploys shared agent instructions, skills, and Pi agent settings. Claude Code and Pi themselves are managed by Omarchy/devcontainers.

## What it does

### Shared configuration

- `~/.agents/AGENTS.md`: global agent instructions (canonical).
- `~/.pi/agent/AGENTS.md`: symlink to the canonical instructions.
- `~/.pi/agent/ollama-cloud.json`: Pi agent settings.
- When `pi` is available, the recipe installs `npm:pi-web-access` and `npm:pi-ollama-cloud` through Pi itself; the resulting package settings remain machine-local.
- `~/.claude/settings.json`: deep-merged Claude settings; local model/hooks/plugins are preserved.
- `~/.claude/statusline.sh` and `~/.claude/output-styles/`: Claude presentation settings.
- The optional `dot-ai-private` overlay remains supported and skips gracefully when unavailable.

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
