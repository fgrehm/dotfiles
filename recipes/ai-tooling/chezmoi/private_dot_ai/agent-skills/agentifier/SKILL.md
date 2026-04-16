---
name: agentifier
description: "Rewrite documents so AI agents follow them more reliably. Use when optimizing CLAUDE.md, AGENTS.md, READMEs, runbooks, specs, or any instructional document for AI consumption. Applies context engineering patterns: attention-aware structure, positive framing, token efficiency, canonical examples, consistent terminology, and explicit degrees of freedom. Do NOT use on code files, configs, or content that humans read but agents do not."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# Agentifier: Optimize Documents for AI Agents

You are a context engineer that restructures documents so AI models follow their instructions more reliably. Human-readable prose often buries intent in ways that degrade model performance. This skill applies research-backed patterns to fix that.

Follow the process at the end of this document. The patterns below are your toolkit.

---

## ATTENTION AND STRUCTURE

### 1. Front-load and back-load critical instructions

Models exhibit a U-shaped attention curve: accuracy is highest for information at the beginning and end of context, with a 30%+ drop for content in the middle (Liu et al., 2023). Place the most important instructions first. Put secondary reminders or checklists at the end.

**Before:**
> ## Project overview
>
> This is a Next.js e-commerce app with Stripe integration. We use PostgreSQL for persistence and Redis for caching. The app has been in production since 2023 and serves roughly 50k monthly users.
>
> ## Development workflow
>
> We use feature branches and squash merges. PRs need one approval.
>
> ## Important rules
>
> Never modify the migrations folder directly. Always run tests before committing. Use the `pnpm` package manager, not npm or yarn.

**After:**
> ## Rules
>
> - Use `pnpm` exclusively (not npm or yarn)
> - Never modify `migrations/` directly
> - Run `pnpm test` before every commit
>
> ## Project context
>
> Next.js e-commerce app, Stripe payments, PostgreSQL + Redis. Production since 2023, ~50k MAU.
>
> ## Workflow
>
> Feature branches, squash merge, one PR approval required.

**Why:** Rules moved to the top where attention is strongest. Project context condensed (the model does not need to know the founding story). The word "Important" as a section header does nothing for a model; the position does.

---

### 2. Use structured sections with clear delimiters

Organize content into labeled sections using markdown headers or XML tags. Models parse structured documents more accurately than flowing prose.

**Before:**
> When you're working on this project, keep in mind that we use TypeScript everywhere and all functions should have return types. Also, our API layer uses tRPC so make sure you use the router pattern. For styling we use Tailwind and we prefer utility classes over custom CSS. Tests go in `__tests__` directories next to the code they test.

**After:**
> ## Language
>
> TypeScript. All functions must have explicit return types.
>
> ## API
>
> tRPC with the router pattern.
>
> ## Styling
>
> Tailwind utility classes. No custom CSS.
>
> ## Tests
>
> Co-located in `__tests__/` directories next to source files.

**Why:** Each concern gets its own section. The model can locate and follow individual constraints without parsing a paragraph.

---

### 3. Flatten deeply nested references

When a document references another file that references another file, models often partially read or skip the chain. Keep references one level deep.

**Before:**
> See CONTRIBUTING.md for details. (CONTRIBUTING.md says: "See docs/workflow.md for the branching strategy." workflow.md says: "See docs/git-conventions.md for commit message format.")

**After:**
> ## References
>
> - Branching strategy: [docs/workflow.md](docs/workflow.md)
> - Commit message format: [docs/git-conventions.md](docs/git-conventions.md)
> - Full contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)

---

## FRAMING AND CLARITY

### 4. Positive framing over negation (the Pink Elephant Problem)

Telling a model *not* to do something forces it to process the unwanted concept first. Reframe every prohibition as a positive instruction.

**Before:**
> Don't use mock data in tests. Don't import from the old `@company/utils` package. Don't forget to handle errors.

**After:**
> Use real fixtures from `tests/fixtures/` in all tests. Import from `@company/utils-v2` exclusively. Wrap external calls in try/catch with specific error types.

**Why:** "Only use real data" outperforms "don't use mock data" in compliance benchmarks. The model's first token prediction steers toward the desired behavior instead of the forbidden one.

---

### 5. Replace vague guidance with specific heuristics

Models comply better with concrete instructions than abstract advice. If a human would need to ask "what does that mean in practice?", the model will also struggle.

**Before:**
> Be careful with database migrations. Make sure error handling is thorough. Keep code clean and well-organized.

**After:**
> - Run `pnpm db:migrate --dry-run` before applying any migration
> - Every `fetch()` call must have a catch block that logs the URL and status
> - Files over 300 lines should be split; functions over 40 lines should be extracted

**Why:** "Be careful" is not actionable. A dry-run command, a specific error handling pattern, and numeric thresholds give the model concrete targets.

---

### 6. Set explicit degrees of freedom

Tell the model when to follow instructions exactly versus when to use judgment. Ambiguity about how much latitude the model has causes both over-compliance and under-compliance.

**Before:**
> Use the standard deployment process. Format code appropriately. Write tests for new features.

**After:**
> ## Deployment (follow exactly)
>
> Run `./scripts/deploy.sh staging` first. After QA approval, run `./scripts/deploy.sh production`. Do not modify the script or add flags.
>
> ## Code formatting (defer to tooling)
>
> `pnpm format` runs Prettier on save. Do not manually adjust formatting.
>
> ## Tests (use judgment)
>
> New features need tests. Choose the appropriate level (unit, integration, e2e) based on what the feature touches. Prefer unit tests for pure logic, integration tests for API endpoints.

**Why:** The model now knows that deployment is a rigid sequence, formatting is not its job, and test strategy is a decision it should make contextually.

---

## TOKEN EFFICIENCY

### 7. Strip common knowledge

Models already know what React is, how git works, and what a REST API does. Only include information the model does not already have: your project's specific decisions, constraints, and conventions.

**Before:**
> ## About PostgreSQL
>
> PostgreSQL is a powerful, open-source relational database management system. It uses SQL for querying and supports ACID transactions. In this project, we use PostgreSQL 15 with the `pgvector` extension for embedding storage. Our connection pool is configured for 20 max connections via PgBouncer.

**After:**
> ## Database
>
> PostgreSQL 15 with `pgvector` for embeddings. PgBouncer connection pool, 20 max connections.

**Why:** 70% of the tokens were spent explaining what PostgreSQL is. The model already knows. The project-specific details (version, pgvector, PgBouncer, pool size) are what it actually needs.

---

### 8. Compress filler and hedging

Remove preambles, qualifiers, throat-clearing, and meta-commentary. Every token competes for the model's attention budget.

**Before:**
> It's important to note that, in order to maintain code quality and ensure a consistent developer experience, all team members should ideally try to follow these guidelines as closely as possible when working on the project.

**After:**
> Follow these guidelines.

**Before:**
> Please note that you might want to consider using the newer API endpoint if possible, as it could potentially provide better performance in some situations.

**After:**
> Use the v2 API endpoint. It is faster.

---

### 9. Use examples instead of exhaustive rules

A few well-chosen input/output pairs communicate behavior more precisely than paragraphs of description. For models, examples are "pictures worth a thousand words."

**Before:**
> Commit messages should follow conventional commits format. The type should be one of feat, fix, chore, docs, refactor, test, or ci. The scope is optional but recommended when it clarifies which component changed. The description should be in present tense, lowercase, and under 72 characters. Use the body for additional context when the change is complex. Reference issues when relevant.

**After:**
> ## Commit format
>
> Follow conventional commits. Examples:
>
> ```
> feat(auth): add OAuth login support
>
> fix: resolve memory leak in background worker
>
> chore(deps): update React to v19
>
> refactor(api): split user router into sub-routers
>
> Moved /users/preferences and /users/notifications into dedicated
> router files to reduce complexity in the main user router.
>
> Fixes #342
> ```

**Why:** The examples encode all the rules (type, scope, tense, length, body, issue reference) without stating them. The model pattern-matches from examples more reliably than it parses rule descriptions.

---

## CONSISTENCY AND MAINTENANCE

### 10. One term per concept

Synonym variation confuses models about whether you mean the same thing or different things. Pick one term and repeat it.

**Before:**
> The API endpoint returns user data. The route provides customer information. The path delivers account details.

**After:**
> The `/users` endpoint returns user data.

**Why:** "Endpoint", "route", and "path" might mean the same thing or might not. The model cannot tell. Consistent terminology removes ambiguity.

---

### 11. Isolate time-sensitive information

Dates and versions inline become silently wrong. Put them in clearly marked sections that are easy to find and update.

**Before:**
> As of March 2026, we're using Node 22. We'll migrate to Node 24 when it hits LTS in October. The old API (v1) is deprecated but still works for now; switch to v2 when you can.

**After:**
> ## Current versions
>
> - Node: 22 (LTS)
> - API: v2 (v1 deprecated, removal date TBD)

---

### 12. Defer to tooling for enforceable rules

If a linter, formatter, or CI check can enforce a rule deterministically, do not spend tokens telling the model about it. The model's output will be corrected by the tool anyway, and the instruction wastes attention budget.

**Before:**
> Use 2-space indentation. Always add trailing commas. Use single quotes for strings. Sort imports alphabetically. Add semicolons at the end of statements. Use `const` instead of `let` when the variable is not reassigned.

**After:**
> Prettier and ESLint enforce formatting. Run `pnpm lint` to verify.

**Why:** Six instructions replaced by one. The model's attention is freed for instructions that only the model can follow.

---

## DOCUMENT-TYPE-SPECIFIC GUIDANCE

### CLAUDE.md / AGENTS.md files

These load into every session and compete with the system prompt for attention. Frontier models can follow ~150-200 instructions with reasonable consistency; Claude Code's system prompt already uses ~50 of those.

- Keep under 300 lines, ideally under 100
- Only include universally applicable instructions (not task-specific ones)
- Use `@imports` or file references for context that is only sometimes relevant
- Structure: Rules first, then project context, then workflow, then references

### READMEs and onboarding docs

These are often read once by the model at the start of a task.

- Lead with what the project *is* (one line) and how to run it
- Put "getting started" commands in a fenced code block, not prose
- Move architecture details to a separate file the model can read when needed

### Runbooks and operational docs

These are followed step-by-step under time pressure (or by an agent in a loop).

- Number every step
- Use exact commands in fenced code blocks
- Include expected output or success criteria for each step
- Add validation checkpoints: "Verify X before continuing"

### Specs and design docs

These provide context for implementation decisions.

- Lead with the goal and constraints, not background
- Separate "must have" from "nice to have" explicitly
- Include acceptance criteria as a checklist the model can work through

---

## Process

1. Read the input document
2. Identify which patterns above apply
3. Restructure, applying transformations in priority order:
   a. Front-load critical instructions (pattern 1)
   b. Add structure (pattern 2)
   c. Reframe negations as positives (pattern 4)
   d. Replace vague with specific (pattern 5)
   e. Strip common knowledge (pattern 7)
   f. Compress filler (pattern 8)
   g. Swap rules for examples where effective (pattern 9)
   h. Apply remaining patterns as relevant
4. Count approximate instruction density; flag if over ~150 instructions
5. Audit: "What in this document would a model most likely misfollow or ignore?"
6. Fix the flagged areas
7. Present the final version

## Output Format

Provide:
1. The restructured document
2. A brief list of changes made (which patterns were applied and where)
3. If applicable, warnings about instruction density or scope issues

---

## References

This skill synthesizes context engineering research from multiple sources:

- [Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Goldilocks zone, minimal token sets, examples over rules
- [Anthropic: Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) - Conciseness, degrees of freedom, progressive disclosure
- [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) - Instruction density limits, attention degradation
- [Builder.io: How to write a good CLAUDE.md](https://www.builder.io/blog/claude-md-guide) - Practical structure patterns
- [Liu et al., 2023](https://arxiv.org/abs/2307.03172) - "Lost in the middle" U-shaped attention curve
- [OpenAI: Prompt engineering guide](https://platform.openai.com/docs/guides/prompt-engineering) - Positive framing, iterative refinement

## Related skills

For prose aimed at human readers rather than agents, see the `humanizer` skill.
