---
name: tracer-bullet
description: >
  Plan and execute risky technical changes by identifying the riskiest assumption,
  designing a minimal end-to-end test that validates it, then growing the implementation
  in phased red-green-refactor cycles. Produces a persistent plan file for multi-session
  continuity.

  Use when: (1) a proposed approach has an assumption that could invalidate the entire
  design, (2) migrating to a new architecture or integration pattern, (3) adopting an
  unfamiliar technology or API, (4) any multi-session implementation where validating
  feasibility early saves significant rework.

  Trigger phrases: "tracer bullet", "validate the approach", "riskiest assumption",
  "prove this works first", "thin vertical slice".

  Do NOT use for: single-file changes, well-understood patterns, tasks where the
  approach is known to work, or pure refactoring of existing code.
---

# Tracer Bullet

Test the riskiest assumption first with a thin end-to-end slice. Then grow the
implementation in disciplined phases.

Three techniques, one workflow: RAT (what to validate), tracer bullet (how to validate
it), red-green-refactor (execution cadence).

## Guardrails

These are hard constraints. Apply them throughout both stages.

- **One assumption per tracer bullet.** Testing two at once means you cannot tell which one failed.
- **Automated tests, not console output.** The tracer bullet must produce a test that can be re-run.
- **Exit criteria before execution.** Define pass/fail before writing the test, not after seeing results.
- **Phase 0 is mandatory.** Execute it before Phase 1. Never combine them.
- **Plan is append-only during execution.** Update progress checkboxes and add learnings. Restructure phases only with user approval.
- **Keep the tracer bullet code.** It becomes the skeleton for the full implementation.

## Workflow

Two stages: **Plan** then **Execute**.

### Stage 1: Plan

#### 1. Read context

Read CLAUDE.md, .ai/MEMORY.md, existing tests, and CI config. Understand the stack,
test framework, and project conventions before asking questions.

#### 2. Interview (3-4 questions max)

Ask targeted questions with concrete tradeoffs. Present choices, not open-ended prompts.

**Always ask:**
- What is the riskiest assumption? Lead with your best guess based on codebase exploration, then let the user confirm or correct.
- What does "done" look like for the tracer bullet? (Minimal proof the assumption holds.)

**Ask when relevant:**
- Testing tools and environment constraints?
- Backward compatibility requirements?
- Work in progress that affects the plan?
- Execution environment: containers, CI, local, specific platforms?

Skip questions whose answers are in the codebase.

#### 3. Classify the risk

Identify which type applies, then design the tracer bullet accordingly.

| Risk type | Question it answers | Tracer bullet design |
|---|---|---|
| Integration | Will external tool X accept input Y? | Call the tool with real inputs; assert expected outputs |
| Performance | Can this handle N items in T time? | Benchmark with realistic data volume |
| Feasibility | Is this possible with the current API? | Minimal proof-of-concept exercising the critical API surface |
| Data | Does the data actually look like we assume? | Load real data; assert shape and invariants |

An integration risk needs a real end-to-end test against the external system. A
feasibility risk may need only a unit test exercising the API.

#### 4. Design the tracer bullet (Phase 0)

The tracer bullet must:
- Test exactly one riskiest assumption
- Touch all critical layers end-to-end (not a single isolated component)
- Use production-quality code and real tooling
- Run in the project's actual test infrastructure
- Have a clear exit criterion: pass = proceed, fail = pivot or spike an alternative

#### 5. Write the plan

Look for an existing plan file convention (`.ai/plan.md`, `docs/plan.md`, `plans/`). If none exists, ask the user where they want it. Gitignore session-specific state.

```markdown
# [Title]

## Context
Why this change is needed. What problem it solves. 1-2 paragraphs.

## Riskiest assumption
One sentence. What could kill the approach.

## Phase 0: Tracer bullet
Goal, test design, exit criterion (pass = proceed, fail = pivot to what).

## Phase 1..N: Implementation phases
Each phase:
- Goal (one sentence)
- Key changes (files, functions, behaviors)
- Red-green-refactor cycle: what test to write first, what makes it pass
- Commit message

## Progress
- [ ] Phase 0: Tracer bullet
- [ ] Phase 1: ...
- [ ] Phase N: ...
```

Keep phases small enough to complete in one session. Each phase produces one commit.
Order phases by dependency (what must exist before what), not by difficulty.

### Stage 2: Execute

#### Run Phase 0 first

This is the go/no-go gate.

- **Pass**: Assumption holds. Mark Phase 0 complete in the plan. Proceed to Phase 1.
- **Fail**: Stop. Document what was learned. Either pivot to an alternative approach
  (design a new tracer bullet for it) or spike to acquire more knowledge before deciding.

#### Run remaining phases

For each subsequent phase, use `/red-green-refactor`:
1. Write a failing test (red)
2. Make it pass (green), commit
3. Refactor, commit
4. Mark phase complete in the plan
5. Verify the full test suite passes before moving to the next phase

#### Multi-session continuity

The plan file is the coordination artifact between sessions. At session end, ensure it
reflects current progress. At the start of every session, read the plan file before
doing anything else.

## Related skills

- `/red-green-refactor`: Execution for Phase 1+. Tracer bullet owns planning and Phase 0.
- `/technical-spec-writer`: For larger changes needing a formal spec before planning. The spec feeds the plan's context section.
- `/end-of-session`: Flush plan progress and learnings to disk.
