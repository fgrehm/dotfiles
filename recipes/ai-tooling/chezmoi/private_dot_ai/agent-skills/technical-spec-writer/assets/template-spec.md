# [Feature/Refactoring Title]

**Date:** YYYY-MM-DD
**Status:** Draft

## Goal

[1-3 sentences explaining what this spec accomplishes and why it matters]

[Optional: If large, list workstreams/sections]
- 1. Section title
- 2. Section title
- 3. Section title

---

### TDD Approach

Every section follows test-first development. Task lists are ordered: **write tests, then implement to make them pass.** Tests should be written against the intended interface/behavior before the production code exists. The test describes what correct looks like; the implementation makes it true.

### Test Infrastructure

All tests must follow these patterns for isolation and cleanup:

[Include relevant patterns from SKILL.md: temp directories, context setup, etc.]

---

## 1. [First Section Title]

### Current State

[How things work now, or the problem we're solving]

### Design

[The approach, including architecture decisions, pseudocode, or implementation details]

### Tasks

Tests first:

- [ ] **Test:** [specific behavior]
- [ ] **Test:** [specific behavior]

Implement:

- [ ] [specific implementation task]
- [ ] [specific implementation task]

---

## 2. [Second Section Title]

### Design

[The approach]

### Tasks

Tests first:

- [ ] **Test:** [specific behavior]

Implement:

- [ ] [specific implementation task]

---

## Implementation Order

Recommended sequencing (some tasks can be parallelized; dependencies noted):

1. **Section 1** -- [reason: foundational / unblocks others / etc.]
2. **Section 2** -- [reason: depends on Section 1 / independent / etc.]

**Parallelizable:** After step X, steps Y-Z can start in parallel. Step Y must finish before step Z can finish.

---
