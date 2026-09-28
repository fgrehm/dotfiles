---
name: flush
description: "Persist session state at a pause or handoff. Use when the user says flush, checkpoint, save progress, save context, let's wrap up, end of session, or signals a pause."
---

# Flush

Persist only state that lets the next session resume safely. Use the repository's `.agents/` workspace:

- `.agents/context/main.md`: short project-wide index. Pi and Claude Code load this file automatically when valid (and warn if unapproved by default; `PROJECT_CONTEXT_STRICT=1` requires approval).
- `.agents/context/resume.md`: current task handoff in this checkout. It is not auto-loaded; agents read it when resuming work.
- `.agents/scratchpad/`: supporting plans, research, and separate handoffs when concurrent work needs them. These files are local and ignored.
- Canonical repository docs: durable decisions and facts that belong with the codebase.

Use [the resume template](references/resume-template.md) when starting a handoff. Create only files the work needs.

## Rules

1. Read existing `.agents/context/main.md` and `.agents/context/resume.md` before changing either. Update confirmed state in place; preserve unfinished handoffs in `.agents/scratchpad/` before switching tasks.
2. Keep `main.md` under 8 KiB. Put only project-wide state and pointers there, not session history. Do not duplicate instructions from `AGENTS.md`, facts in `README.md`, code, or Git history; link to the source when useful.
3. When `main.md` changes, report that its SHA-256 changed. The loaders warn but auto-load unapproved versions by default; with `PROJECT_CONTEXT_STRICT=1` they require renewed approval.
4. Keep `resume.md` current-state-first: task, status, exact next step, blockers, and links to detail, followed by at most 10 dated, one-paragraph entries for meaningful sessions. Do not record every conversation.
5. Keep scratchpad files resumable: goal, confirmed facts, current status, and exact next step. Ask before deleting untracked `.agents/` files or replacing uncertain local state.
6. Ask before committing. Stage files explicitly by name.

## Process

### 1. Check Git state

Use built-in tools to inspect:

- `git status` for staged and unstaged changes.
- `git log @{u}..HEAD` (or the last 10 commits when no upstream exists) for unpushed commits.
- `git diff --unified=0 HEAD` filtered for TODO, FIXME, or HACK annotations added in this session.

Ask whether to commit any uncommitted work.

### 2. Reconcile session artifacts

Review the session for state worth preserving.

Update `.agents/context/resume.md` for the current task's status, exact next step, blocker or pending human decision, and links to supporting files. Add a dated session paragraph only when the session meaningfully changed the state or direction; keep the newest 10. When switching tasks, preserve the unfinished handoff in `.agents/scratchpad/` and replace `resume.md` only after checking existing state.

Update `.agents/context/main.md` only when project-wide state or a pointer to active work changes. Keep it an index, not a transcript. Do not copy information already available from repository docs, code, or Git history.

Create or update `.agents/scratchpad/<topic>.md` for detailed analysis, plans, research, or concurrent-task handoffs that would otherwise require rediscovery. Link relevant detail from `resume.md` or `main.md`.

### 3. Trim completed work and update canonical documentation

When work is complete, remove its active pointer from `main.md` and review the finished `resume.md` for cleanup. Ask before deleting untracked files, including a finished resume or stale scratchpad plans and handoffs. Promote durable project facts to repository docs instead of duplicating them in local context; ask the user about ambiguous promotions. Keep completed work discoverable through the repository and Git history, not a growing context log.

### 4. Surface dangling work

Identify unresolved agent annotations, skipped tests, incomplete implementation, and pending decisions. Record the next step in `resume.md` (or the relevant concurrent-task handoff) and ask the user how to proceed if judgment is required.

## Report

Summarize:

- Git state, commits, and unpushed work.
- `main.md` changes and approval status under the current loader policy.
- `resume.md` and scratchpad artifacts created or updated, and any cleanup needing permission.
- Canonical docs changed.
- Dangling work and the next step.
