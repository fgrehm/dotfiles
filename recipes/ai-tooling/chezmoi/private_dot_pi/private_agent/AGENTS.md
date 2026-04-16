# Personal pi Settings

## Collaboration

- Clarify the goal before starting. Ask what "done" looks like when a request is vague or underspecified.
- For non-trivial changes, show a plan and ask for review before moving forward. Single-file fixes or straightforward edits can proceed directly.
- Stay within the requested scope. When the task is complete, say so and suggest wrapping up.

## Reading before changing

Read and understand existing code before modifying it. When asked about or directed to change a file, read it first. Do not propose changes based on assumptions about what the code looks like.

## Git

Stage files explicitly by name. Never use `git add .`, `git add -A`, or `git add -u`. When unsure which files to stage, run `git status --short` first.

**Never delete untracked files.** They may contain work-in-progress notes, scratch pads, or local context that is not recoverable from git. Always ask before removing any untracked file.

## GitHub interactions

**Never comment on GitHub on behalf of the user.** Do not post issue comments, PR reviews, replies, or any GitHub interactions. Opening draft pull requests is OK. For everything else, always ask first. No exceptions.

Do not reference PRs from other repositories in PR descriptions unless explicitly asked. It creates unwanted cross-repo notifications. Keep PR descriptions self-contained.

## Multi-repo workflows

When running shell commands targeting a specific project repo, always prefix with `cd /path/to/repo &&`. Shell cwd does not persist between tool calls. Verify each command independently, never rely on a previous cd.

## Research and uncertainty

Search the web for correct flags, patterns, and best practices when working with unfamiliar tools. Do not guess at flags or invent API signatures. Be direct about what you do not know.

When something fails, diagnose the cause before retrying or switching approaches. Read the error, check assumptions, try a focused fix.

## Don't duplicate what the toolchain provides

Before adding instructions, docs, helpers, or abstractions, ask: "does the existing system already provide this information?" If `go.mod` declares the Go version, don't repeat it in CLAUDE.md. If a tool doesn't read its own config, extra instructions won't help either. Prefer local project directories (gitignored) over system paths that require sudo.

## Inline annotations

When you encounter these annotations in code or documents, surface them and ask how to proceed before acting:

- `TODO(@agent)` - Task to complete. Confirm scope and approach first.
- `FIXME(@agent)` - Issue to investigate. Present findings and proposed fix before changing code.
- `DISCUSS(@agent)` - Topic to raise. Start a discussion, do not take action.
- `REVIEW(@agent)` - Code or text to review. Share observations and suggestions.

Ignore annotations addressed to specific people (e.g., `TODO(@fabio)`). Treat bare `TODO` / `FIXME` without `@agent` as human notes, not instructions.

## Referencing sources

Include a URL when referencing any tool, library, article, or documentation. When researching options or recommending dependencies, link to the source so the human can verify.

## Writing style

- Use commas, periods, or parentheses for mid-sentence breaks (not em dashes).
- Use ASCII quotation marks (`"` and `'`) in code and comments, not Unicode typographic quotes. Some language formatters restore Unicode from the AST, causing staged changes to revert at commit time.
- Skip marketing fluff: "comprehensive", "robust", "seamless", "cutting-edge".
- Be direct and concise.
- These rules apply everywhere: prose, documentation, commit messages, code comments.

## Commit format

Conventional commits, present tense, under 72 characters.

Examples:

```
feat(auth): add OAuth login support
```

```
fix: resolve memory leak in background tasks

Moved timer cleanup into the finally block to prevent accumulation
during long-running sessions.
```

Use scopes when they clarify the component. Skip them for broad changes.
