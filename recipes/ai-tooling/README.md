# ai-tooling

Deploys shared agent instructions, skills, and Pi agent settings. Claude Code and Pi themselves are managed by Omarchy or the surrounding devcontainer/VM environment.

## What it does

### Shared configuration

- `~/.agents/AGENTS.md`: global agent instructions (canonical).
- `~/.pi/agent/AGENTS.md`: symlink to the canonical instructions.
- `~/.agents/pi/{ollama-cloud,web-search}.json`: Pi provider settings, linked into `~/.pi/agent/` on machines that do not have another owner for those paths (see below).
- `~/.pi/agent/extensions/pi-footer.ts`: Claude-style Pi footer showing project, session, Git branch, provider/model, thinking level, context usage, token totals, cache totals, and cost.
- `~/.pi/agent/extensions/pi-quit.ts`: Pi quit aliases for `/exit`, `/quit`, bare `exit`, and Vim-style `:q`, `:wq`, and `:x` variants.
- Omarchy only, `~/.pi/agent/extensions/subagent/`: a vendored copy of Pi's subagent extension example, which registers the `subagent` tool. Each call spawns a child `pi` process with an isolated context window, and the tool supports single, parallel (up to 8 tasks, 4 concurrent), and sequential chain dispatch.
  - Source: `earendil-works/pi` at `packages/coding-agent/examples/extensions/subagent`, pinned by commit in `VENDOR.md` next to the code. MIT, Copyright (c) 2025 Mario Zechner. Both files are byte-identical to upstream with no local modifications, and upstream `README.md` is kept alongside them.
  - Agents come from `~/.pi/agent/agents/*.md`. This recipe ships one generic `delegate` agent with no tool or model restrictions, so the parent model picks it on its own and you can name a model per call. Upstream's `scout`/`planner`/`worker`/`reviewer` samples and the `/implement` prompt templates are intentionally not shipped: their prompts only restate an ordering the model can infer, and every one pins an Anthropic model that this setup does not have.
  - Upstream exposes no recursion guard (`pi-subagents` has one), so keep an eye on nested delegation. The vendored copy is excluded from Prettier in the Makefile so a re-vendor does not produce an unreviewable diff.
  - Re-vendor after a Pi upgrade: `recipes/ai-tooling/scripts/vendor-pi-subagent.sh --check` reports whether upstream moved, and running it with no arguments rewrites the pinned copy and `VENDOR.md`.
- When `pi` is available, the recipe makes sure `pi-web-access` (>= 0.36.0) and `pi-ollama-cloud` (>= 0.12.2) are installed through Pi itself. On Omarchy hosts it also installs `@juicesharp/rpiv-ask-user-question` (>= 2.12.0), which registers the `ask_user_question` tool for structured multi-option questions instead of the model guessing. Install it on its own; it does not require the rest of the `rpiv-pi` pipeline (its only peer, `rpiv-i18n`, is optional and falls back to untranslated strings). The vendored subagent example and this package are both gated on `isOmarchy`, which stands in for "not driven by bb": containers and VMs normally run agents through [bb](https://getbb.app), which supplies its own agent tooling, so installing them there would duplicate it. Once bb detection exists as template data, gate on that instead. These versions are floors, not pins: a machine below a floor gets the newest release installed unpinned, and a machine already at or above it is left alone. The script also strips version pins from these entries in `~/.pi/agent/settings.json`, since a pinned entry never moves, not even through `pi update --extensions` (this is what frees machines whose home-seed manager pinned the packages). Other packages in `settings.json`, including any pins another manager owns, are untouched, and the package settings themselves remain machine-local.
- `~/.claude/settings.json`: deep-merged Claude settings; local model/hooks/plugins are preserved.
- `~/.claude/statusline.sh` and `~/.claude/output-styles/`: Claude presentation settings.

### Container behavior

Containers keep ownership of configuration supplied by their image or runtime. Existing global `AGENTS.md` and Pi policy/provider JSON files are preserved; when a container has not supplied one, the recipe seeds and links its default. Portable skills, Pi extensions, Claude presentation settings, and the non-destructive Claude settings merge still apply. Agents in containers and VMs normally run through [bb](https://getbb.app), which supplies its own tooling, so the vendored subagent example and `rpiv-ask-user-question` stay Omarchy-only for now.

### Link policy (never overwrite)

The link scripts (`link-pi-home`, `link-claude-home`, `link-skills`) only create missing symlinks. If the target path already holds a real file, it is left alone even when it matches our content byte-for-byte: that file belongs to another manager or the user, and that manager stays authoritative for the path (a VM image seed rewriting its files, a container runtime, or a hand-configured tool). The same applies to symlinks the scripts do not own; the scripts' own correct links are skipped, and only a stale link pointing elsewhere under `~/.agents` is repointed.

The Pi provider and sandbox JSON files (`ollama-cloud.json`, `web-search.json`, `sandbox.json`) are a common claim for home-seed managers. Because seeds write their files at boot, the link scripts skip them on those machines as long as the files exist; a link is only created if the file is absent at apply time, so do not install these dotfiles on a machine before its home seed has run.

### Shared skills

Skills live once at `~/.agents/skills/<name>/` (the canonical cross-client home) and are exposed to each tool via individual symlinks:

- `~/.claude/skills/<name>` -> `~/.agents/skills/<name>`
- `~/.pi/agent/skills/<name>` -> `~/.agents/skills/<name>`

A `run_onchange_after_link-skills.sh.tmpl` script creates these symlinks for every skill in `~/.agents/skills/` and re-runs whenever the skill set changes. It only creates missing symlinks, so anything else you drop into `~/.agents/skills/` (or the per-agent dirs) is left alone. The omarchy skill already lives in `~/.agents/skills/` and coexists.

### Project continuity context

Pi and Claude Code load a valid `<git-root>/.agents/context/main.md` as project-state context. It is limited to 8 KiB and must be a regular UTF-8 file inside the Git root. By default, both loaders **warn but still load** an unapproved or changed file, including in non-interactive sessions. Set `PROJECT_CONTEXT_STRICT=1` to require approval of each SHA-256 version before loading. Approvals are shared at `~/.agents/project-context-trust.json`. To review and approve the file for both clients from the project root, run:

```sh
~/.agents/bin/project-context-hook --approve
```

In strict mode, Pi can prompt for approval in its interactive TUI; Claude Code prints the approval command. `/project-context` refreshes Pi's loaded context and offers review in strict interactive mode. Only `main.md` is auto-loaded. Keep it as a short project-wide index, not a session log. `.agents/context/resume.md` holds the current task handoff in this checkout and must be opened explicitly; use `.agents/scratchpad/` for supporting plans, research, and concurrent-task handoffs. The [flush skill](chezmoi/private_dot_agents/skills/flush/SKILL.md) contains a resume template and guidance for trimming completed work.

To vendor a third-party skill from GitHub, use the helper under this recipe:

```sh
recipes/ai-tooling/scripts/vendor-skill.sh https://github.com/owner/repo/tree/main/path/to/skill
```

It pins the skill to a commit SHA and writes the vendored copy under `recipes/ai-tooling/chezmoi/private_dot_agents/skills/<skill>/`.
