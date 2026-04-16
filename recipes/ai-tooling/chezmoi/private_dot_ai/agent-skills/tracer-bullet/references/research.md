# Tracer Bullet Skill: Research and Sources

Background research that informed this skill's design. The skill combines three established techniques (RAT, spike, tracer bullet) with red-green-refactor execution into a single planning workflow for AI coding agents.

## Core concepts

### Tracer bullets (Hunt & Thomas, 1999)

Thin end-to-end slices through all system layers. Production-quality code, not disposable. Build when you know what you need to do but aren't sure what it'll look like.

- [The Pragmatic Programmer, Chapter on Tracer Bullets](https://flylib.com/books/en/1.315.1.25/1/)
- [How Tracer Bullets Speed Up Software Development (Built In)](https://builtin.com/software-engineering-perspectives/what-are-tracer-bullets)
- [Tracer Bullets (C2 Wiki)](https://wiki.c2.com/?TracerBullets=)
- [Barbarian Meets Coding: Tracer Bullets notes](https://www.barbarianmeetscoding.com/notes/books/pragmatic-programmer/tracer-bullets/)
- [Tracer Bullet Development (Gunnar Peipman)](https://gunnarpeipman.com/tracer-bullet-development/)

### GROWS Method: Tracer Bullet Development

Formalized the practice as a development methodology. Key insight: the tracer bullet becomes the skeleton you grow the rest of the system onto.

- [GROWS Tracer Bullet Development (overview)](https://growsmethod.com/grows_tracer_bullets.html)
- [GROWS Tracer Bullet Development (practice)](https://growsmethod.com/practices/TracerBullets.html)

### Riskiest Assumption Test (RAT)

Rik Ingram (2016). Identify the assumption that would kill your project if wrong, then test it before building anything. Provides the framework for deciding *what* to validate.

- [ModelThinkers: Riskiest Assumption Test](https://modelthinkers.com/mental-model/riskiest-assumption-test)
- [Keenethics: Riskiest Assumption Test](https://keenethics.com/riskiest-assumption-test)
- [Cadabra Studio: Validate Ideas Before MVP](https://cadabra.studio/blog/riskiest-assumption-test/)
- [Design a Better Business: Riskiest Assumption Canvas](https://www.designabetterbusiness.tools/tools/riskiest-assumption-canvas)

### Research -> Spike -> Tracer Bullet progression

Three techniques for managing different bands of uncertainty. Research when you have the vaguest idea. Spike when you know what to do in theory but not implementation. Tracer bullet when you know the approach but not the scope.

- [My Agile Diary: Spike vs Tracer Bullet](https://www.myagilediary.com/tracer-bullet/)
- [Tinned Fruit: Shoot Down Front-End Fatigue With Tracer Bullets](https://tinnedfruit.com/writing/shoot-down-front-end-fatigue-with-tracer-bullets.html)
- [Mind & Logic: Spike, Tracer Bullet, Abnormal Termination](https://mindandlogic.wordpress.com/2013/11/06/rarely-utilized-scrum-practices-spike-tracer-bullet-abnormal-termination/)

## AI agent context

### Tracer bullets for AI coding agents

"The principles apply harder to AI than they ever did to humans. Context window constraints make the discipline non-negotiable."

- [AI Hero: Tracer Bullets: Keeping AI Slop Under Control](https://www.aihero.dev/tracer-bullets)
- [DEV.to: Tracer Bullets for AI Concepts: Rapid POC Validation](https://dev.to/rakbro/tracer-bullets-for-ai-concepts-rapid-poc-validation-3ci)

### Four Modalities for Coding with Agents

Gene Kim & Steve Yegge's framework. Tracer bullets are the core of "Guided Prototyping" -- low upfront spec, high review. Let the agent fire a thin end-to-end slice, inspect it to validate the architecture.

- [DEV.to: The Four Modalities for Coding with Agents](https://dev.to/eabait/the-four-modalities-for-coding-with-agents-4cdf)

### Agent workflow patterns

- [AI Hero: A Complete Guide To AGENTS.md](https://www.aihero.dev/a-complete-guide-to-agents-md)
- [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Medium: The 3 Amigo Agents Pattern](https://medium.com/@george.vetticaden/the-3-amigo-agents-the-claude-code-development-pattern-i-discovered-while-implementing-anthropics-67b392ab4e3f)

## Gap this skill fills

None of the sources describe an automated workflow combining RAT + tracer bullet + red-green-refactor into a reusable planning tool for AI agents. The pieces exist separately:

- RAT gives you the *what* to test
- Tracer bullet gives you the *how* (thin vertical slice)
- Red-green-refactor gives you the *execution cadence*

This skill codifies the full cycle as a repeatable workflow.
