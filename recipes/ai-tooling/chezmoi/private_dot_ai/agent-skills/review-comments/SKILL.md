---
name: review-comments
description: Fetch PR review comments using the gh-pr-review extension. Auto-detects current PR. Defaults to latest Copilot review. Read-only (no write operations).
---

# Review Comments

Read-only access to inline PR review threads via the [gh-pr-review](https://github.com/agynio/gh-pr-review) extension. Single GraphQL call, pre-joined thread context, structured JSON output.

## Prerequisites

```sh
gh extension install agynio/gh-pr-review
```

## Default: latest Copilot review

```sh
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
PR=$(gh pr view --json number -q .number)
gh pr-review review view \
  --reviewer copilot-pull-request-reviewer \
  -R "$REPO" --pr "$PR" \
  | jq '{reviews: [.reviews[-1]]}'
```

The `jq` slice keeps only the latest Copilot review. Copilot may post multiple reviews as you push; without it you'd see all accumulated feedback at once.

## Filters

| Flag | Purpose |
|---|---|
| `--reviewer <login>` | Filter by reviewer login (e.g. `copilot-pull-request-reviewer`, `octocat`) |
| `--unresolved` | Only show unresolved threads |
| `--not_outdated` | Exclude threads on outdated diff hunks |
| `--tail <n>` | Keep only last n replies per thread |
| `--states <list>` | `APPROVED`, `CHANGES_REQUESTED`, `COMMENTED`, `DISMISSED` |

## All reviews (final pass before merging)

```sh
gh pr-review review view \
  --reviewer copilot-pull-request-reviewer \
  -R "$REPO" --pr "$PR"
```

Drop the `jq` filter to see all reviews, not just the latest.

## How I'll Use This

1. Auto-detect `$REPO` and `$PR` from git context
2. Run the default command (`--reviewer copilot-pull-request-reviewer` unless told otherwise)
3. Summarize feedback by category
4. Create an action plan: what needs fixing vs. what's already addressed
5. Implement fixes
