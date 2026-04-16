# fact-checker

Verifies factual claims in your writing before publishing. Works with any agent that supports the [SKILL.md format](https://agentskills.io/what-are-skills).

## What it does

Runs a structured verification pass on blog posts, technical specs, tool comparisons, and similar content:

1. Extracts every verifiable claim from the text
2. Categorizes claims by risk (pricing/versions are high-risk, general concepts are lower)
3. Searches for evidence using web search
4. Flags common AI slop patterns: confident unsourced specificity, outdated defaults, fabricated references
5. Reports issues with sources and suggested fixes

## Setup

Drop the `fact-checker/` folder into your agent's skills directory. `context: fork` and `model:` frontmatter fields are Claude Code-specific and will be ignored by other agents.

```bash
cp -r fact-checker /path/to/your/project/.claude/skills/fact-checker
```

The skill uses `context: fork` in its frontmatter, which tells Claude Code to run it in an isolated subagent context, keeping verification work out of your main conversation.

> [!NOTE]
> `context: fork` has [known reliability issues](https://github.com/anthropics/claude-code/issues/18394) in Claude Code as of early 2026. If the skill runs inline instead of forking, you can create a [subagent](https://code.claude.com/docs/en/sub-agents) in `.claude/agents/fact-checker.md` with `skills: [fact-checker]` to guarantee isolation.

## Usage

```
Fact-check this blog post: [paste or attach draft]
```

## Requirements

- An agent with web search capability (no additional APIs or dependencies)

## References

- [FacTool](https://github.com/GAIR-NLP/factool). Tool-augmented framework for factuality detection in LLM outputs. The claim extraction, evidence retrieval, verdict pattern used in this skill is based on this approach.
- [The Perils and Promises of Fact-Checking with Large Language Models](https://www.frontiersin.org/journals/artificial-intelligence/articles/10.3389/frai.2024.1341697/full). Research on using LLM agents with iterative search for claim verification.
- [LLM Misinformation Research Paper List](https://github.com/ICTMCG/LLM-for-misinformation-research). Curated list of fact-checking and misinformation detection papers using LLMs.
- [Equipping Agents for the Real World with Agent Skills](https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills). Anthropic's guide to the SKILL.md format.
- [Claude Code Subagents Docs](https://code.claude.com/docs/en/sub-agents). Official docs for creating custom subagents with isolated context windows.
- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills). Official docs for skill frontmatter including `context: fork`.
