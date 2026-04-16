---
name: claude-project-sync
description: Extract and distill project knowledge for Claude.ai Projects. Use when the user wants to generate or update a set of files to upload to a Claude.ai Project so they can discuss the codebase in claude.ai conversations. Triggers on requests like "sync to claude project", "generate project knowledge", "update claude.ai project files", or "extract knowledge for claude.ai".
---

# Claude Project Sync

Generate a set of distilled files for a Claude.ai Project from the current codebase. The output is a directory of files the user can copy-paste or upload to their Claude.ai Project.

Read [references/claude-projects.md](references/claude-projects.md) for how Claude.ai Projects are structured.

## Workflow

### 1. Explore the codebase

Gather context before writing anything:

- Read CLAUDE.md if present (project instructions, build commands, architecture notes)
- Read documentation directories (docs/, README files)
- Scan source tree structure (package/module map, key responsibilities)
- Check manifest files for dependencies (go.mod, package.json, pyproject.toml, Cargo.toml, etc.)
- Check build/config files (Makefile, docker-compose, CI configs, etc.)
- Note what's built vs. planned (look for TODOs, roadmap docs, specs for unbuilt features)

### 2. Check for existing output

Look for an existing output directory (e.g., `docs/claude-project/`). If it exists, read the current files to understand what's already been written. Prefer updating over rewriting from scratch.

### 3. Generate artifacts

Write files to a `docs/claude-project/` directory (or wherever the user specifies). Generate these files:

**`description.txt`** (for the Project description field)
- 1-2 sentences. What the project is, what language, what stage.
- No instructions or behavioral guidance.

**`instructions.md`** (for the Project instructions field)
- How the user works on the project (e.g., "I use Claude Code for implementation, these conversations for design")
- Writing style preferences (pull from CLAUDE.md if present)
- Spec/doc conventions
- Keep it short. Do NOT put architecture or feature details here.

**Knowledge files** (for upload as Project knowledge)
- Distill the codebase into 2-4 focused files depending on project size and complexity.
- Common splits: architecture, current state/feature inventory, domain-specific system docs (e.g., skill system, API surface, data model).
- Each file should be self-contained and non-overlapping with the others.
- Include what's built AND what's planned, clearly distinguished.
- Include dependency lists, test approach, key constraints.
- Prefer tables and bullet points over prose. These are reference docs, not narratives.

### 4. Present the result

Show the user what was generated, where each file goes in Claude.ai, and note which files would need periodic updates (e.g., current-state changes more often than architecture).

## Guidelines

- **Distill, don't dump.** The goal is context-efficient knowledge, not a copy of every doc. Summarize, deduplicate, and cut what Claude already knows (language basics, common library APIs).
- **Separate concerns.** Instructions tell Claude how to behave. Knowledge files tell Claude what to know. Description tells the human what the project is.
- **Reflect reality.** If something isn't built yet, say "planned" or "not yet implemented". Don't describe aspirational features as current.
- **Respect the user's CLAUDE.md.** Pull writing style preferences (em dash rules, tone, etc.) into the instructions file.
- **Date the state.** Include a "Last updated" date on files that track current state.
