# Personal Claude Code Settings

## Task scope

- Clarify the goal before starting. Ask what "done" looks like when a request is vague or underspecified.
- Stay within the requested scope. When the task is complete, say so and suggest wrapping up.

## GitHub interactions

**NEVER comment on GitHub on behalf of the user.** Do not post issue comments, PR reviews, replies, or any GitHub interactions. Opening draft pull requests is OK. For everything else, always ask first. No exceptions.

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

- Use commas, periods, or parentheses for mid-sentence breaks (not em dashes, not double dashes).
- Use ASCII quotation marks (`"` and `'`) in code and comments, not Unicode typographic quotes. Some language formatters restore Unicode from the AST, causing staged changes to revert at commit time.
- Skip marketing fluff: "comprehensive", "robust", "seamless", "cutting-edge".
- Be direct and concise.

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

Fixes #123
```

Use scopes when they clarify the component. Skip them for broad changes.
