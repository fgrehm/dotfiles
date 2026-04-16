---
name: project-inception
description: "Structured project inception through interview, documentation, and scaffolding. Use when starting a new project (CLI tools, libraries, web apps, backends, etc.) to conduct a detailed interview about vision/scope/tech, generate foundational documentation (README with philosophy, CLAUDE.md for AI context, ROADMAP for phased plan), and scaffold initial code structure with git setup. Adapts questions and outputs based on project type. Do NOT use for existing projects. Use only when starting from scratch."
---

# Project Inception

## Overview

This skill guides the creation of new projects through a structured inception process. Rather than jumping straight to code, it captures the project's vision, philosophy, architecture decisions, and build plan in documentation before writing a line of code.

The workflow:
1. **Interview** - Ask clarifying questions about the project (adapted by type)
2. **Document** - Generate README (with philosophy), CLAUDE.md (for AI context), and ROADMAP (phased plan)
3. **Scaffold** - Create initial directory structure and git setup with commits

## Quick Start

**Triggering this skill:**
- User says "start a new project" or "help me inception this project"
- User provides a project idea/description and asks for help structuring it
- User wants documentation and planning before diving into code

**Basic flow:**
1. Ask what type of project (or infer from description)
2. Run the interview for that project type (see "The Interview" section)
3. Generate documentation based on interview responses
4. Optional: scaffold initial code structure

## The Interview

The interview is the heart of inception. It captures:
- **What** the project is and who it's for
- **Why** it exists (philosophy, problem it solves)
- **How** it's built (tech stack, architecture decisions)
- **When** it ships (MVP scope, roadmap phases)

### Project Type Detection

First, determine the project type. This shapes which interview questions are asked:

- **CLI Tool**: Command-line interface, single executable, focus on user interaction and command structure
- **Library**: Reusable package for other projects, public API, versioning matters
- **Web App**: Browser-based UI, backend, frontend, deployment
- **Backend Service**: API/service for other services to consume, scalability/monitoring
- **Personal Tool**: For one person's use, filesystem-native, privacy-conscious, lower production needs

Ask: "What type of project is this?" If unclear, infer from the description.

### Interview Questions

See [references/interview_questions.md](references/interview_questions.md) for the complete question list organized by project type.

**Generic approach:**
- Start with high-level questions (vision, problem, users)
- Follow with tech/architecture questions
- End with MVP and roadmap questions
- Adapt based on responses (ask follow-ups, skip irrelevant questions)

### Universal questions (ask these for every project)

1. What does this project do in one sentence?
2. Who is the primary user? (yourself, a team, the public)
3. What's the MVP, the minimum version worth shipping?
4. What tech stack, and why? (or: any constraints on tech choice?)
5. What does "done" look like for phase 1?

For project-type-specific questions, see
[references/interview_questions.md](references/interview_questions.md).

**Keep it conversational:** These aren't a rigid quiz. Ask natural follow-ups, skip questions if already answered, reword for clarity.

### Summarizing Interview Responses

After the interview, summarize what you learned:

```
Project: [Name]
Type: [CLI/Library/Web App/etc.]
Vision: [1-2 sentence purpose]
Tech Stack: [Languages, frameworks, deployment]
MVP Scope: [What ships first]
Key Philosophy: [Unique approach/constraint]
```

This becomes the foundation for documentation generation.

## Documentation Generation

Generate three core documents from interview responses:

### 1. README.md

**Structure:**
- Title and tagline
- "What is this?" section
- Philosophy/principles section
- Architecture overview
- MVP features
- Tech stack (table format)
- Open questions
- Development status

See [references/documentation_templates.md](references/documentation_templates.md#readme) for full template.

### 2. CLAUDE.md

**Structure:**
- "What this is" summary
- Tech stack
- Directory layout (XDG Base Directory Spec if applicable)
- Architecture decisions
- MVP scope
- Code style guidelines
- Standards and conventions
- Repository info

See [references/documentation_templates.md](references/documentation_templates.md#claudemd) for full template.

**Key principle:** CLAUDE.md is for future AI assistants. Write it as a context document that helps Claude understand the project without needing to explore the codebase.

### 3. ROADMAP.md

**Structure:**
- Phased plan (Phase 1: Foundation, Phase 2: Core features, Phase 3+: Polish/Beyond MVP)
- Within each phase, numbered items with dependencies
- "Suggested build order" section listing the critical path

See [references/documentation_templates.md](references/documentation_templates.md#roadmap) for full template.

## Tech-Specific Scaffolding

After documentation, optionally scaffold code structure based on tech stack.

**When to scaffold:**
- User asks for it
- Project has clear scaffolding patterns (CLI with Cobra, React app, Python library)
- MVP is defined and ready to start

**Common patterns:**

- **Go CLI with Cobra**: Create cmd/main.go, cmd/root.go, cmd/subcommands.go, Makefile
- **Python CLI**: Create pyproject.toml, src/package/__main__.py, tests/
- **Web App (React)**: Create frontend/, backend/, package.json/go.mod, Dockerfile
- **Library (Go/Python)**: Create src/, tests/, docs/, example/, LICENSE

**Ask before scaffolding:** "Should I create the initial code structure?" - don't assume.

## Standards and Conventions

Always follow established standards. See [references/standards_checklist.md](references/standards_checklist.md) for the full checklist.

Key ones:
- **XDG Base Directory Spec** for file paths (when applicable)
- **Conventional Commits** for git messages
- **ISO 8601** for dates and timestamps
- **YAML** for config files
- **JSONL** for logs
- OpenAI-compatible APIs, OpenGraph for metadata, etc.

## Git Setup

Initialize git repo and create initial commits:

1. `git init`
2. Add docs: `git add README.md CLAUDE.md ROADMAP.md`
3. Commit: `git commit -m "docs: add project README, CLAUDE.md, and ROADMAP with initial spec"`
4. If scaffolded code: `git add <code files>` and commit with appropriate message

Use Conventional Commits format (feat, fix, chore, docs, etc.) in commit messages.

## Workflow Decision Tree

```
START: "Help me inception a new project"
  ├─ Ask: "What type of project?"
  │   ├─ [CLI Tool] → Use CLI interview
  │   ├─ [Library] → Use Library interview
  │   ├─ [Web App] → Use Web App interview
  │   ├─ [Backend] → Use Backend interview
  │   └─ [Personal Tool] → Use Personal Tool interview
  ├─ Run the interview for that type (ask questions, listen for answers)
  ├─ Summarize responses
  ├─ Generate README, CLAUDE.md, ROADMAP
  ├─ Ask: "Should I scaffold initial code?"
  │   ├─ [Yes] → Create code structure
  │   └─ [No] → Skip to git setup
  ├─ Initialize git repo and make initial commits
  └─ END: "Your project is ready to build!"
```

## Tips

- **Don't over-engineer the interview.** If the user has already decided on tech, scope, and philosophy, skip those questions.
- **Write docs as if explaining to a future self.** Imagine opening this project 6 months from now with no context - would these docs help?
- **Philosophy matters.** The README philosophy section captures why the project exists. Spend time on this.
- **CLAUDE.md is critical.** This is what keeps AI assistants productive in future sessions. Include architecture decisions, not just tech stack.
- **Roadmap phases should be actionable.** "Phase 1: Foundation" is better than "Phase 1: Setup stuff." Name the actual components being built.
