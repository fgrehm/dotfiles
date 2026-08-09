# Documentation Templates

## README.md

The user-facing project overview. Update it as the project evolves.

```markdown
# [Project Name]

[One-sentence tagline capturing the core value/philosophy]

## What is this?

[1-2 paragraph description of what the project is and who it's for. Should answer:
- What problem does it solve?
- Who is it for?
- What makes it different?]

## Philosophy

[Optional but recommended: a section explaining the design philosophy.
Why did you build it this way? What did you prioritize?
Include bullet points about core values/principles.]

## Core principles

[List of 4-6 bullets describing key aspects:
- Filesystem-native / Cloud-first / etc.
- Simplicity / Flexibility / etc.
- Cost-conscious / Performance-focused / etc.
- etc.]

## Architecture

[Technical architecture overview:
- What's the main stack?
- How do the pieces fit together?
- Where does data live?
- What are the major components?]

## MVP features

[What does the first version do?
- Feature 1
- Feature 2
- Feature 3

Include code examples or usage if relevant.]

## Tech stack

[Table format:]

| Component | Choice |
|-----------|--------|
| Language | |
| Framework | |
| Database | |
| Deployment | |

## Open questions

[Known unknowns that will be decided later:
- Question 1
- Question 2]

## Development

[Project status and where it's hosted:
- This is a [public/private] project
- Hosted at: [URL]
- Status: [Alpha/Beta/Stable/etc.]
- Will be [open-sourced/released] when...]
```

## CLAUDE.md

AI assistant context. This is what keeps Claude productive across sessions.

```markdown
# [Project Name] - Project Context

## What this is

[1-2 sentence summary of what the project is. Copy from README if needed.]

## Tech stack

- [Language] with [Framework]
- [Database/Storage]
- [Deployment]
- [Other key technologies]

## Directory layout

[If using XDG Base Directory:
- Config: `$XDG_CONFIG_HOME/appname/`
  - `config.yaml`
  - `agents/`
- Data: `$XDG_DATA_HOME/appname/`
  - `data/`
  - `cache/`
- State: `$XDG_STATE_HOME/appname/`
  - `logs/`

Or custom layout:
- `src/` - source code
- `tests/` - test files
- `docs/` - documentation
- etc.]

## Architecture decisions

- **Key decision 1**: Rationale
- **Key decision 2**: Rationale
- **Data storage**: Where and how data is persisted
- **API design**: If applicable, how the API is structured
- **Concurrency model**: How async/parallel stuff works
- **Error handling**: Philosophy on error handling
- **Testing**: Testing strategy

## MVP scope

[What the first version includes:
- Feature 1
- Feature 2
- Feature 3]

## Code style

- Keep it simple. No over-engineering.
- [Language-specific conventions]
- [Naming conventions]
- [Other style guidance]

## Standards and conventions

[What standards does this project follow?
- HTTP standards? OAuth? OpenAI API format?
- File formats? (YAML, JSON, JSONL, etc.)
- Timestamps? (ISO 8601?)
- Directory structure? (XDG Base Directory Spec?)
- Git conventions? (Conventional Commits?)
- Exit codes? (Standard Unix conventions?)]

## Repository

- Location: [URL]
- Status: [Private/Public]
- [Will be open-sourced/released when...]
```

## ROADMAP.md

Build plan broken into phases.

```markdown
# [Project Name] Roadmap

## Phase 1: Foundation

[The minimum pieces needed before anything else can work]

### 1.1 [First component]
- Detail 1
- Detail 2
- Acceptance criteria

### 1.2 [Second component]
- Detail 1
- Detail 2

## Phase 2: Core features

[The main functionality that makes the project useful]

### 2.1 [Feature 1]
- Detail 1
- Detail 2

### 2.2 [Feature 2]
- Detail 1
- Detail 2

## Phase 3: Polish and daily driver

[Making it good enough for regular use]

### 3.1 [Quality improvement 1]
### 3.2 [Quality improvement 2]

## Phase 4: Beyond MVP

[Nice-to-haves and future directions]

### 4.1 [Future idea 1]
### 4.2 [Future idea 2]

---

## Suggested build order for getting to usable state

[Priority-ordered list of what to build first:
1. **Component A** - critical path item
2. **Component B** - depends on A
3. **Component C** - adds value but not blocking
etc.]

[Each item should note dependencies and why it matters.]
```

## Key Principles for Documentation

### README
- **Written for users.** Explain what the project does, why they should care, and how to use it.
- **Includes philosophy.** The philosophy section is not marketing; it's explaining the design choices and tradeoffs.
- **Up-to-date.** When features change, update the README. When architecture changes, update the docs.
- **Concrete examples.** Show code snippets, command examples, or usage patterns.

### CLAUDE.md
- **Written for future AI assistants.** Imagine opening this project 6 months from now with no context. What would Claude need to know?
- **Architecture over tech stack.** Yes, include the tech stack, but the real value is explaining WHY those choices were made and how the system fits together.
- **Decision rationale.** Include the reasoning behind key choices, not just the choices themselves.
- **Conventions matter.** Document the standards and conventions so future work stays consistent.

### ROADMAP
- **Phased thinking.** Break work into clear phases with dependencies.
- **Actionable items.** "Phase 1: Foundation" is too vague. "Phase 1.1: Config + data directory" is better.
- **Critical path.** The "Suggested build order" section should list what MUST be built before other things can work.
- **Living document.** Update the roadmap as phases are completed and new insights emerge.

## Example: pAIr00t

The pairoot project uses all three documents:

1. **README.md** - Explains that it's a personal AI assistant, emphasizes the philosophy (filesystem-native, cost-conscious, anti-sycophant), shows MVP features
2. **CLAUDE.md** - Explains the architecture (intent routing → cheap models → frontier models), directory layout (XDG spec), and standards (Conventional Commits, JSONL for logs, ISO 8601)
3. **ROADMAP.md** - Breaks work into 4 phases with clear dependencies (config first, then sessions, then features, then polish)

Together, they give a complete picture of the project that persists across sessions.
