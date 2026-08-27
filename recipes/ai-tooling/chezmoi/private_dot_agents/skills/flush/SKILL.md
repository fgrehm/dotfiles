---
name: flush
description: "Persist session state at a pause or handoff. Use when the user says flush, checkpoint, save progress, save context, let's wrap up, end of session, or signals a pause."
---

# Flush

Persist only state that lets the next session resume safely. Use the repository's `.agents/` workspace:

- `.agents/context/main.md`: short, durable project-state index. It is auto-loaded by approved Pi and Claude Code sessions.
- `.agents/scratchpad/`: detailed reviews, plans, investigations, and handoffs. These files are local and ignored.
- Canonical repository docs: project decisions that belong with the codebase and should be shared.

## Rules

1. Read existing `.agents/context/main.md` before changing it. Keep its current confirmed state and update it in place.
2. Keep `main.md` under 8 KiB. Record active state, durable decisions, and links to detailed artifacts. Put detail in `scratchpad/`.
3. When `main.md` changes, tell the user it requires renewed SHA-256 approval before Pi or Claude Code loads the new version.
4. Keep scratchpad files resumable: goal, confirmed facts, current status, and exact next step.
5. Never delete untracked `.agents/` files. Ask before removing or replacing uncertain local state.
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

Update `.agents/context/main.md` for:

- Active work that the next session needs immediately.
- Confirmed decisions, constraints, or cross-client workflow preferences.
- Links to the relevant scratchpad artifact.

Create or update `.agents/scratchpad/<topic>.md` for:

- Detailed analysis, plans, incomplete implementation, or a handoff.
- Facts established during the session that would otherwise require rediscovery.
- The exact next step and any pending human decision.

Do not add derivable code facts, stale task narration, or detailed logs to `main.md`.

### 3. Update canonical documentation

Update project docs only when the session established a durable project fact that belongs in version control. For ambiguous promotions from local context to repository docs, ask the user.

### 4. Surface dangling work

Identify unresolved agent annotations, skipped tests, incomplete implementation, and pending decisions. Record a concrete next step in the relevant scratchpad file, then ask the user how to proceed if judgment is required.

## Report

Summarize:

- Git state, commits, and unpushed work.
- `main.md` changes and whether renewed Pi/Claude approval is needed.
- Scratchpad artifacts created or updated.
- Canonical docs changed.
- Dangling work and the next step.
