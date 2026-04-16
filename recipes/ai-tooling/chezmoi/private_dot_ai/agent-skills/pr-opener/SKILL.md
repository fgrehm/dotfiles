---
name: pr-opener
description: "Automate pull request creation with intelligent verification and semi-interactive workflow. Use when ready to open a PR after completing work. The skill verifies task completion from conversation history, checks unpushed code, reads the repo's PR template, generates a suggested title and description combining git log and conversation context, and opens a draft PR via gh. Semi-interactive shows the proposal for confirmation/editing before creating."
---

# PR Opener

## IMPORTANT: Start Immediately

When this skill loads, **do not wait for the user to prompt you further**. Begin the workflow below right away. The user already asked for a PR by invoking this skill.

## Workflow

Execute these steps in order:

### 1. Verify completion
Review the conversation history to confirm all planned work is done. If anything looks incomplete, flag it before proceeding.

### 2. Gather git context
Run these in parallel:
- `git log origin/main..HEAD --oneline` — commits to include
- `git diff origin/main..HEAD --stat` — files changed
- Check if branch has unpushed commits: `git rev-list --count --left-only @{u}...HEAD 2>/dev/null || echo "not-pushed"`

### 3. Read the PR template — REQUIRED

**You MUST read the PR template file before writing any PR description.** Use the Read tool to load it:

```
Read: .github/PULL_REQUEST_TEMPLATE.md
```

If that path doesn't exist, try `.github/pull_request_template.md`. If neither exists, use a plain Summary + Changes structure.

The template defines the exact sections and format the repo expects. Your PR description must follow it. Remove HTML comment blocks and omit sections that don't apply.

### 4. Determine issue link keyword

Default to `Related to #N` (leaves the issue open). Only use `Fixes #N` or `Closes #N` if the user confirms this PR fully resolves the issue.

If there is a linked issue number visible in the conversation or branch name, include it.

### 5. Generate the proposal

Using the template structure, git log, and conversation context, draft:
- **Title**: concise, under 72 characters, following any repo commit conventions (e.g. conventional commits)
- **Body**: filled-out template with irrelevant sections removed and correct issue keyword

Present the proposal to the user as plain text so they can review it:

```
Here's the proposed PR:

**Title:** <title>

**Body:**
<body>

Does this look good, or would you like to change anything?
```

Wait for confirmation before proceeding.

### 6. Push and open

Once the user approves:
1. Push if needed: `git push -u origin HEAD`
2. Create the draft PR: `gh pr create --draft --title "..." --body "..."`
3. Return the PR URL to the user

## Configuration

- **Draft mode**: PRs are created as drafts by default
- **Base branch**: Always targets `origin/main` unless the user specifies otherwise
- **PR template**: Always read before writing the description — never skip this step
