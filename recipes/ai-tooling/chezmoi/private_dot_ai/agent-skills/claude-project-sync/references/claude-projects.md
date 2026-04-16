# Claude.ai Projects Reference

## Structure

A Claude.ai Project has three configurable parts:

1. **Project description**: Short blurb visible in the project list. 1-2 sentences. Identifies what the project is about at a glance.

2. **Project instructions** (custom instructions field): Behavioral guidance for Claude within the project. Tells Claude how to respond, what style to use, what role to assume. Not a knowledge dump. Think of it as a system prompt.

3. **Project knowledge** (uploaded files): Documents Claude can reference during conversations. These provide the actual context: architecture, APIs, current state, domain knowledge. Supported formats include text, code, PDFs, and more.

## Constraints

- Knowledge files share the context window with conversation history and system prompt.
- Keep files focused and non-overlapping. Redundancy wastes tokens.
- Large files are fine but Claude may not read them fully on every turn.

## Best Practices

- Description: what the project is (for the human browsing projects)
- Instructions: how Claude should behave (tone, style, role, workflow preferences)
- Knowledge files: what Claude needs to know (architecture, state, domain facts)

Keep instructions short. Put factual content in knowledge files, not instructions.
