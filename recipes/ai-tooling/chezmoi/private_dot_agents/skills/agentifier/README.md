# Agentifier

A skill that rewrites documents so AI agents follow them more reliably. The opposite of [humanizer](../humanizer/), instead of removing AI patterns from text, this adds structure that models parse and comply with better.

## What it does

Takes a human-written document (CLAUDE.md, AGENTS.md, README, runbook, spec, onboarding guide) and restructures it using research-backed context engineering patterns:

| Pattern | What it fixes |
|---|---|
| Front-load critical instructions | Important rules buried in the middle get ignored (U-shaped attention) |
| Structured sections | Prose paragraphs that bury multiple instructions |
| Positive framing | "Don't do X" triggers the forbidden concept first |
| Specific heuristics | Vague guidance like "be careful" that models can't act on |
| Explicit degrees of freedom | Ambiguity about when to follow exactly vs. use judgment |
| Strip common knowledge | Wasting tokens explaining things models already know |
| Compress filler | Hedging, preambles, and meta-commentary that dilute signal |
| Examples over rules | Paragraphs of description where input/output pairs work better |
| Consistent terminology | Synonym cycling that creates ambiguity |
| Isolate time-sensitive info | Inline dates/versions that silently go stale |
| Flatten references | Nested reference chains that models partially read |
| Defer to tooling | Style rules that linters enforce deterministically |

## Usage

In Claude Code:

```
/agentifier

[paste or point to your document]
```

Or ask directly:

```
Agentify my CLAUDE.md so models follow it better
```

## Sources

Synthesized from context engineering research, not vendored from a single upstream.

### Primary sources

- **[Anthropic: Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)** (Sep 2025) - Core framework for the skill. Introduced the "Goldilocks zone" for instruction specificity, the principle of minimal token sets, preferring canonical examples over exhaustive rules, and structured formatting with XML/markdown sections. Also the source for the "most agent failures are context failures" framing.

- **[Anthropic: Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)** - Official Claude skill docs. Source for the degrees-of-freedom model (high / medium / low), progressive disclosure patterns, the "challenge each token" heuristic, one-level-deep reference rule, and the advice to defer enforceable rules to linters.

- **[Liu et al., 2024 - Lost in the Middle: How Language Models Use Long Contexts](https://arxiv.org/abs/2307.03172)** - The research paper behind pattern #1 (front-load critical instructions). Demonstrated a U-shaped performance curve: 30%+ accuracy drop when relevant information is buried in the middle of context, consistent across every model tested.

### Secondary sources

- **[HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)** - Quantitative data on instruction density limits (~150-200 instructions for frontier thinking models, exponential decay for smaller models). Source for the "~50 instructions already in system prompt" figure and the observation that irrelevant instructions cause uniform degradation across all directives.

- **[Builder.io: How to write a good CLAUDE.md](https://www.builder.io/blog/claude-md-guide)** - Practical structure patterns for CLAUDE.md files. Reinforced the "rules first, context second" ordering and the use of `@imports` for conditional context.

- **[OpenAI: Prompt engineering guide](https://platform.openai.com/docs/guides/prompt-engineering)** - Source for the "Pink Elephant Problem" (positive framing over negation) and iterative refinement methodology. Also documents the distinction between reasoning models (high-level guidance) and GPT models (precise instructions).

## License

MIT
