---
name: red-green-refactor
description: >
  Disciplined implementation workflow following the red-green-refactor-commit cycle.
  Invoke explicitly via /red-green-refactor or suggest when the user describes a
  non-trivial multi-file implementation task, feature addition, or significant code
  change. Do NOT suggest for single-file fixes, typos, or trivial changes.
---

# Red-Green-Refactor

A structured implementation loop that produces clean, tested, committed code in two
phases: first make it work (green + commit), then make it right (refactor + commit).

## Phase 0: Discovery

Before writing code, establish the project's verification commands. Check the project
root for Makefile, package.json, Cargo.toml, pyproject.toml, go.mod, etc.

Identify and confirm with the user:
- **Build**: how to compile/typecheck (e.g., `make build`, `go build ./...`, `tsc`)
- **Test**: how to run tests (e.g., `make test`, `pytest`, `go test ./...`)
- **Lint**: how to lint (e.g., `make lint`, `eslint .`, `golangci-lint run`)

If any command is missing, note it and proceed without it. Use a task list to track
progress through the phases.

## Phase 1: Green

Goal: working code with passing tests.

1. **Read before writing.** Read every file you intend to modify. Understand existing
   patterns, naming conventions, and test styles before changing anything.
2. **Implement incrementally.** Work in small, compilable steps. Run build after each
   logical chunk to catch errors early rather than accumulating a big-bang diff.
3. **Write tests alongside code.** For new public functions/types, add tests in the
   same pass. Match the project's existing test style and naming. Start with one
   tracer-bullet test that proves the end-to-end path works before covering edge cases.
   Tests should verify behavior through public interfaces, not implementation details --
   a test that breaks on internal renaming without a behavior change is testing the wrong
   thing. Per-cycle sanity check: test describes observable behavior / uses public
   interface only / would survive an internal refactor / code is minimal for this test.
4. **Verify green state.** Run build + test + lint. Fix any failures. Do not proceed
   until all three pass cleanly.

## Phase 2: Commit (green)

Lock in the working state. Stage only the files you changed. Write a conventional
commit message that describes the feature, not the implementation mechanics.

## Phase 3: Refactor

Goal: reduce duplication, improve structure, without changing behavior.

1. **Analyze systematically.** Scan the changed files and their neighbors for:
   - Duplicated logic that could be shared
   - Functions that are too long or do too many things
   - Dead code, unused exports, unnecessary abstractions
   - Inconsistent patterns (error handling, naming, structure)
   - Integration seams or awkward bridging between old and new code
   - Performance issues (unnecessary allocations, missing reuse)
2. **Prioritize.** Group findings into high/medium/low priority. High = duplicated code,
   real bugs, performance issues. Medium = readability, consistency. Low = stylistic,
   future-proofing. Present the list to the user and get approval on scope.
3. **Implement top-down.** Work through approved items from high to low priority. After
   each change, verify build + test + lint still pass.
4. **Stop when diminishing returns.** If remaining items are low-priority and the code
   is clean, stop. Document deferred items somewhere discoverable (e.g., in a spec,
   TODO comments, or an issue tracker).

## Phase 4: Commit (refactor)

Same as Phase 2. The commit message should start with `refactor:` or `refactor(scope):`
and summarize what was cleaned up.

## Guardrails

- **Never skip verification.** Every phase boundary (green, refactor) must pass
  build + test + lint before committing.
- **Never combine green and refactor in one commit.** The point of two commits is that
  the first is a known-good checkpoint. If refactoring breaks something, you can revert
  to the green commit.
- **Never refactor without approval.** Present the analysis and let the user pick which
  items to address. Some "improvements" aren't worth the churn.
- **Keep refactoring behavior-preserving.** If a refactoring item changes behavior (e.g.,
  fixing a bug found during analysis), call it out explicitly and get confirmation.
- **Never write all tests before all code.** Writing tests in bulk ("horizontal slicing")
  produces tests that verify imagined behavior and data shapes rather than real behavior.
  One test, one implementation, repeat -- each test responds to what you learned from the
  previous cycle.

## Related skills

When implementation is done, use `pr-opener` to open a PR.

For quick, unstructured cleanup of already-committed code (no cycle, no approval flow), use `/simplify`. It is a built-in Claude Code slash command (not available in pi or other agents) that reviews changed code for reuse, quality, and efficiency, then fixes issues in one pass. Prefer it when the task is small or post-hoc and the full red-green-refactor cycle would be overkill.
