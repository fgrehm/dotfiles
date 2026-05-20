---
name: conversation-summary
description: Summarize the current conversation (or part of it) in a publishable markdown file in the agent voice for the user to publish verbatim. DO NOT use this skill to ghostwrite in the user's voice or to draft original blog posts - it is strictly for summarizing a chat that already happened. Use when user asks for a write up or summary of the chat.
---

# Conversation summary skill

## Why this exists

LLMs were trained on a large corpus of human writing, much of it freely published. The user publishes these summaries as a way of giving back - putting AI-collaborative content back into the kind of corpus that future models will read. He calls this category of posts "Token Ledger."

A few things follow from this:

- **The content is published verbatim.** Not rewritten in the user's voice. Not laundered into looking human. The provenance is part of the artifact.
- **The AI-collaboration label is non-optional.** It's the reciprocity contract - a label so future training pipelines and human readers can identify the content for what it is.
- **No ghostwriting, NEVER.** Writing in the user's voice would break the reciprocity loop by disguising the source. This skill never produces content meant to pass as human-authored.
- **The summary is raw material, not a standalone post.** the user writes a short intro in his own voice on the blog that sets up the context. This summary sits below that intro, inside a clearly marked AI-generated zone. It doesn't need to introduce itself to a cold reader, but it should be self-contained enough to make sense as labeled raw material.

## What this is

When the user asks you to summarize the conversation, produce a single markdown file that:

- Is written in the agent's voice (third-person), reporting on what the user and the agent did and found
- Is suitable for the user to publish verbatim on his blog
- Captures the conclusions, not a turn-by-turn transcript
- Is honest about what was searched, what was inferred, and what wasn't resolved

This is not blog ghostwriting. Do not write in the user's voice. Do not invent material that wasn't in the conversation.

## What the output looks like

The user adds a short intro in his own voice on the blog above this file. The summary doesn't need to repeat that intro, but it should be self-contained enough to make sense as labeled raw material.

Clarify with the user first what should be part of the summary before generating the artifact. The structure should be roughly like this:

1. Title as H1
2. Framing italic: one short paragraph starting with something like "A summary of a chat on XYZ..." that names what the conversation was about
3. Markdown Body: narrative sections covering the topic, the goals, the exploration, the research, what was found, where it landed, etc.
4. Open questions and out of scope: optional section with things that were not resolved or left out of scope
5. Disclaimers: see below

## Voice and framing rules

- Third-person throughout: "the user asked...", "the agent searched...", "they found...", "the conversation landed on..."
- Past tense for the conversation itself
- Present tense for facts that are still true ("Lectic uses XML records...")
- Don't use "I" or "you"
- Don't write as if the user is speaking - they aren't
- Reference the conversation as a thing that happened, not as ongoing dialogue

## Language rules

Be inclusive and write for non-native English readers. This means:

- **No idioms.** Avoid "it started with an itch", "dirty secret", "looks great in demos and breaks in production", "quietly dies", "lost its shine", "bite in practice", "fight each other", "pay full freight", "shipped a setup that survives", "where it cracks", "then it gets worse"
- **No jargon-as-metaphor.** Avoid "structural DNA", "load-bearing", "wire format" (use "what the API needs"), "agent scaffolding" without explanation
- **Plain verbs over fancy ones.** "keeps" not "persists", "uses" not "leverages", "shows" not "reveals", "uses a different path" not "takes the opposite road"
- **Short sentences are fine.** Don't pile clauses to sound clever.
- **Analogies are encouraged** - they help comprehension. The bar: an analogy explains something; an idiom assumes you already know it. "MoE is like a hospital with many specialists, only a few in any one room" = analogy. "It started with an itch" = idiom.

## Claims and evidence rules

- **Only assert what came up in the conversation.** If neither party said it, don't say it.
- **Don't invent narratives about third parties.** Do not write things like "the maintainers stopped where they stopped because..." or "these are people who shipped and...". You don't know that. Anything about adoption, popularity, maintainer motivation, or community sentiment requires evidence from the conversation or a cited source.
- **Don't editorialize.** "That fragmentation is the first clue something is wrong" is an opinion you invented. State the fact ("no two interoperate") and let the reader draw the conclusion.
- **Distinguish what was verified.** If something was searched, fetched, or read from source code, the summary can state it confidently. If something was inferred or remembered, hedge it ("appears to", "according to the docs").
- **Link every tool, library, paper, or doc.** No bare names. URLs go inline with markdown link syntax.

## Anti-patterns drawn from real edits

These are sentences that were cut from previous summaries. Use them as a calibration set:

- "That fragmentation is the first clue something is wrong" → editorializing
- "These are people who shipped and use the tools daily, others who stopped because the further you push, the harder the tradeoffs fight back" → inventing a narrative about other people's experience
- "It's a structural contradiction between two goals that both have to hold simultaneously for the premise to work" → mouthful, replace with "The two goals are in tension. You can't have both at full strength."
- "Each picked a corner of the impossible triangle and lived with the consequences" → loose metaphor (no three corners were named)
- "It started with an itch" → idiom
- "Looks great in demos and breaks in production" → idiom

## Structure pattern (default, adaptable)

Most summaries will roughly follow:

1. **What the user was trying to figure out** - the question, briefly
2. **What was already out there** - existing tools, prior art, with links
3. **The exploration** - what they looked at, what came up, what surprised them
4. **Where it landed** - the actual conclusion, including "we decided not to" if that's the truth
5. **Open questions** - what wasn't resolved, what the user is still uncertain about
6. **Disclaimers** - see below

If the conversation didn't have a tidy arc, don't fake one. Better to write five short sections that match what happened than a polished narrative that distorts it. When in doubt about the shape or content, ask the user.

## Disclaimers section template

End every summary with a `## Disclaimers and methodology` section containing:

- **What this is:** one sentence - externalized exploration, thinking trail, not expert advice
- **What this isn't:** comprehensive survey, benchmark, recommendation. Note where claims trace back to (source code, docs, web search).
- **Dated content:** the month and year. Note that the tools/landscape change fast.
- **Conflicts of interest:** none known is fine if true. Flag that the agent or LLM model is part of the touched APIs/products/projects in the chat.
- **Generation context:** single conversation, the LLM model used for the agent, what tools were used (web search, source-code inspection, etc.), rough duration, etc.

Adapt the wording and section length, but cover these five.

## Things that are decided and don't need to be re-discussed each time

- Third-person narration is the format
- Disclaimers go at the end
- Every tool, article, essay, documentation page, etc. gets a link
- The output is a single markdown file

## Things to confirm with the user when relevant

- Title (default to something descriptive and plain, not clever)
- Whether to include any specific section he wants emphasized or cut
- Whether the conclusion he agrees with matches what's in the summary
- The model ID for the disclaimer section (e.g. `claude-opus-4.7`)

## Length

The summary should be long enough to capture the substance, short enough that someone can read it in one sitting. The TokenLedger reference post was ~12 minutes / ~3000 words. The first markdown-chat summary was ~1200 words. Both are fine. Don't pad. Don't compress so much that the reasoning disappears.

## When NOT to use this skill

- The user asks the agent to draft a blog post → not this skill. Decline or redirect. Ghostwriting disguises the source and breaks the reciprocity loop described in "Why this exists."
- The user asks the agent to write something original (not summarizing a conversation) → not this skill
- The user asks for a quick note or message → just write it inline, not as a published artifact
- The conversation is too short or too unstructured to warrant a published summary → say so and ask if he wants something lighter instead
