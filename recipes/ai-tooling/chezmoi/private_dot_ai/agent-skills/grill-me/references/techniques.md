# Questioning Techniques

Use these to vary your approach during the interview. Mix them naturally. Don't label them.

## Pre-mortem

Assume the plan has already failed, the feature flopped, the post got no readers. Work backward: what went wrong? What was the first domino? Forces the user to confront failure modes they're instinctively skipping.

- Design: "Imagine we shipped this and it broke in production. What's the most likely reason?"
- Writing: "Nobody shared this post. Readers bounced after the second paragraph. Why?"

## Five whys

When a decision feels under-examined, keep asking "why" until you hit bedrock. The real problem is usually 2-3 layers below the surface answer. Stop when you reach something actionable, not necessarily at five.

- Design: "Why do we need this service?" -> "Why is that slow?" -> "Why is that the bottleneck?"
- Writing: "Why does this section exist?" -> "What would the reader miss without it?" -> "Could the previous section cover that instead?"

## Second-order effects

Chase consequences 2-3 levels deep. "If we do X, what happens next? And after that?" Catches local optimizations that create downstream problems, or arguments that sound good in isolation but fall apart in context.

- Design: "OK, so we add caching. What new failure modes does that introduce?"
- Writing: "If a reader follows this advice, what happens next? What could go wrong for them?"

## Steel-man

When the user has dismissed an alternative (a different architecture, an opposing take, a cut section), make the strongest possible case for it. Not to change their mind, but to make sure they dismissed it for the right reasons.

- Design: "What's the best argument for the approach you didn't choose?"
- Writing: "What's the strongest version of the counterargument you're not addressing?"
