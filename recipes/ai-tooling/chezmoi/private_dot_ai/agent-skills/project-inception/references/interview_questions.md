# Interview Questions by Project Type

## Generic Foundation Questions (Ask all projects)

These capture core vision and philosophy:

1. **What is this project?** (Elevator pitch - 1-2 sentences)
2. **What problem does it solve?** (For whom? Why should they care?)
3. **What's the core philosophy?** (What makes this different? What do you prioritize?)
4. **Who are the users?** (End users? Other developers? You?)
5. **What should NOT be part of this?** (Scope boundaries)

## CLI Tool Interview

Additional questions specific to CLI tools:

1. **Main entry point?** (e.g., `myapp`, `myapp subcommand`)
2. **Key commands/subcommands?** (What are the primary operations?)
3. **User interaction model?** (REPL? Flags? Interactive prompts?)
4. **Configuration?** (Config files? Env vars? Both?)
5. **Output format?** (Plain text? Structured JSON? Colors/styling?)
6. **Error handling philosophy?** (Verbose? Terse? Exit codes matter?)
7. **Platforms?** (macOS, Linux, Windows? All three?)
8. **Distribution?** (Homebrew? GitHub releases? Package managers?)

## Library Interview

Additional questions for libraries/packages:

1. **What's the public API?** (Functions, classes, interfaces?)
2. **Who's the audience?** (Go developers? Python data scientists? etc.)
3. **Versioning strategy?** (Semantic versioning? Stability guarantees?)
4. **Dependencies?** (Few? Many? External dependencies okay?)
5. **Documentation needs?** (API docs? Tutorials? Examples?)
6. **Testing?** (High test coverage required? CI/CD important?)
7. **Distribution?** (PyPI? npm? pkg.go.dev? GitHub releases?)

## Web App Interview

Additional questions for web applications:

1. **Frontend framework?** (React? Vue? Svelte? Vanilla?)
2. **Backend?** (REST API? GraphQL? Server-rendered?)
3. **Database?** (Relational? NoSQL? None?)
4. **Authentication?** (Username/password? OAuth? Session-based?)
5. **Real-time features?** (WebSockets? Polling? None?)
6. **Deployment target?** (Vercel? Heroku? Self-hosted? Mobile?)
7. **Browser support?** (Modern only? IE11? Mobile browsers?)
8. **Performance targets?** (LCP, FID, CLS metrics?)

## Backend Service Interview

Additional questions for backend/API services:

1. **API style?** (REST? GraphQL? gRPC?)
2. **Scale?** (Hundreds of requests/day? Millions? Expected growth?)
3. **Reliability requirements?** (99.9% uptime? 99.99%?)
4. **Data durability?** (In-memory? Persistent database? Backups?)
5. **Monitoring/observability?** (Logging? Metrics? Tracing?)
6. **Deployment?** (Docker? Kubernetes? Traditional VPS?)
7. **Security requirements?** (Authentication? Rate limiting? CORS?)

## Personal Tool Interview

Additional questions for personal/private tools:

1. **Privacy requirements?** (Local-only? Cloud-sync? Encryption?)
2. **Filesystem-native?** (Files as the database? Or traditional database?)
3. **Sync needs?** (Dropbox? Git? Nothing?)
4. **Single-user or multi-device?** (Just your machine? Laptop + phone?)
5. **Maintenance burden?** (Can be abandoned? Must be robust?)
6. **Integration points?** (Other tools? APIs? Standalone?)
7. **Performance/cost?** (CPU-intensive? Cost-sensitive?)

## Tech Stack Questions (All projects)

Ask to finalize the tech stack:

1. **Language choice?** (Why that language?)
2. **Framework/libraries?** (Specific choices? Constraints?)
3. **Database choice?** (If applicable)
4. **Deployment platform?** (Where does it run?)
5. **Development tools?** (Build system? Test framework? Linter?)
6. **CI/CD?** (GitHub Actions? Jenkins? None?)
7. **Code organization?** (Monorepo? Multiple repos? Any conventions?)

## MVP and Roadmap Questions (All projects)

Ask to define what ships first and what comes later:

1. **What's the minimum viable product?** (What's the smallest useful version?)
2. **What can wait?** (Nice-to-haves for post-MVP)
3. **What are the phases?** (Foundation → Core features → Polish → Beyond MVP)
4. **Critical path?** (What must be built before other things can work?)
5. **Delivery timeline?** (When should MVP be ready?)
6. **Success metrics?** (How do you know this is working?)

## Follow-up Questions

Use these to dig deeper based on responses:

- "Can you give an example of...?"
- "Why is that important to you?"
- "What would break if you didn't have...?"
- "How do you see this being used?"
- "Any constraints or limitations?"
- "What's the one thing that can't change?"
