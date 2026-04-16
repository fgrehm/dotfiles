---
name: flush
description: "Flush working context to disk at any point during a session. Use when the user says flush, checkpoint, save progress, save context, let's wrap up, end of session, or signals a pause. Also invoke proactively when context is getting long and the user hasn't explicitly saved progress."
---

# Flush

Persist everything worth keeping from working memory to disk. Works mid-session or at session end, no difference.

## 1. Git state

Using your built-in tools (not a script), check:

- `git status` - uncommitted staged/unstaged changes
- `git log @{u}..HEAD` (or last 10 if no upstream) - unpushed commits
- `git diff --unified=0 HEAD` filtered for TODO/FIXME/HACK - new annotations

If there are uncommitted changes, ask the user if they want to commit.

## 2. Memory

Review the session for learnings worth persisting.

Worth saving:
- Confirmed patterns and architectural decisions
- Gotchas, debugging insights, tool quirks
- User preferences (workflow, naming, communication style)

Not worth saving:
- Session-specific task details or temporary state
- Things already in project docs or derivable from code
- One-off observations that haven't been confirmed

Check existing memory files first. Update existing entries rather than creating duplicates.

## 3. Stale docs

Check whether any project docs are out of date relative to what was built this session: specs, READMEs, changelogs, roadmap entries, status headers, checkboxes. Update what you can confidently fix. For anything ambiguous, ask the user.

## 4. Dangling work

Scan for anything left half-done:

- Unresolved TODOs/FIXMEs added this session
- Tests skipped or marked pending

Flag anything found and ask the user how to handle it.

## 5. Report

Short summary of what was flushed:

- Commits made (count + last hash)
- Docs updated (list)
- Memory entries added/updated (list)
- Dangling items (if any)
- Unpushed commits (remind user)
