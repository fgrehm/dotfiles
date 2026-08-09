# Standards and Conventions Checklist

Before finalizing a project's documentation, ensure it follows established standards instead of inventing custom solutions.

## File System Standards

### XDG Base Directory Specification

**When applicable:** Any project that creates files on disk (CLI tools, personal tools, system services)

**Standards to follow:**
- **Config**: `$XDG_CONFIG_HOME/<appname>/` (~/.config/<appname>/)
- **Data**: `$XDG_DATA_HOME/<appname>/` (~/.local/share/<appname>/)
- **State**: `$XDG_STATE_HOME/<appname>/` (~/.local/state/<appname>/)

**Best practices:**
- Always use environment variables with sensible fallbacks
- Document the layout in CLAUDE.md
- Keep config and data separate from transient state
- Never hardcode `~/.appname/` or similar

**Avoid:** Custom directory hierarchies like `~/.appname/data/sessions/2024/01/` - use the standard XDG paths instead.

## API Standards

### OpenAI-compatible APIs

**When applicable:** Projects using LLM APIs (Claude, OpenAI, local LLMs)

**Standard:** Use the [OpenAI Chat API format](https://platform.openai.com/docs/api-reference/chat/create)

**Benefits:**
- Drop-in compatibility with multiple providers
- Standard message format, response format, streaming
- Client libraries support this format across providers

### REST APIs

**When applicable:** Backend services, web services

**Standards:**
- Resource-oriented URLs: `/api/v1/users`, `/api/v1/users/{id}`
- Standard HTTP methods: GET, POST, PUT, DELETE, PATCH
- Standard status codes: 200 OK, 201 Created, 400 Bad Request, 404 Not Found, 500 Server Error
- JSON request/response format (unless explicitly otherwise)

### OpenGraph Protocol

**When applicable:** Web applications, metadata extraction (bookmarks, content)

**Standard:** Use HTML `<meta>` tags for `og:title`, `og:description`, `og:image`, `og:url`

**Example:**
```html
<meta property="og:title" content="Page Title">
<meta property="og:description" content="Page description">
<meta property="og:image" content="https://...">
<meta property="og:url" content="https://...">
```

## Data Format Standards

### JSON

**Use for:** Structured data, APIs, configuration (when not human-edited)

**Standards:**
- UTF-8 encoding
- Proper escaping of special characters
- Standard types: string, number, boolean, null, array, object
- No comments (JSON doesn't support them)

### JSONL (Newline-Delimited JSON)

**Use for:** Append-friendly log files, streaming data

**Standards:**
- One JSON object per line
- Newline character between records
- No commas between records
- Makes it efficient to append and stream

**Example:**
```
{"timestamp": "2024-01-01T12:00:00Z", "level": "info", "message": "Started"}
{"timestamp": "2024-01-01T12:00:01Z", "level": "error", "message": "Failed"}
```

### YAML

**Use for:** Human-edited configuration files, project metadata

**Standards:**
- Use spaces (not tabs) for indentation
- Proper escaping of special characters
- Keep it readable
- No duplicate keys

**Example:**
```yaml
api:
  key: "value"
  timeout: 30
features:
  - name: auth
    enabled: true
```

### Markdown

**Use for:** Documentation, READMEs, project specs

**Standards:**
- GitHub Flavored Markdown (GFM) for broad compatibility
- Proper heading hierarchy (# → ## → ###, no skipping levels)
- Code blocks with language specifiers
- Tables for structured data
- Links in standard markdown format

## Timestamp Standards

### ISO 8601

**When applicable:** All timestamps, date-based directory names, log entries

**Formats:**
- Date only: `2024-01-15`
- DateTime (UTC): `2024-01-15T12:30:45Z`
- DateTime with timezone: `2024-01-15T12:30:45+05:30`
- Date-based directories: `~/.local/share/app/sessions/2024-01-15/`

**Why:** Human-readable, sortable lexicographically, unambiguous, ISO standard.

**Avoid:** American format (01/15/2024), European format (15/01/2024), other non-standard formats.

## Version Control Standards

### Conventional Commits

**When applicable:** All git repositories

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: A new feature
- `fix`: A bug fix
- `chore`: Build process, dependencies, tooling (no code changes)
- `docs`: Documentation changes
- `style`: Code style (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring without changing behavior
- `test`: Adding or updating tests
- `perf`: Performance improvements

**Examples:**
```
feat(auth): add OAuth login support
fix(database): resolve connection pool leak
chore(deps): upgrade React to v18
docs: update API documentation
```

**Scope rules:**
- Use scopes when they clarify what component/area changed
- Skip scopes for broad/obvious changes
- Keep first line under 72 characters when possible
- Use present tense: "add" not "added"
- Reference issues/PRs: `fixes #123`

## Exit Codes

**Standard Unix exit codes:**
- `0` - Success
- `1` - General error
- `2` - Command-line syntax error
- `126` - Command cannot execute
- `127` - Command not found
- `130` - Terminated by Ctrl+C (SIGINT)

**Project-specific codes** (if needed, start at 3+, document them)

## Environment Variables

**Naming convention:**
- UPPERCASE_WITH_UNDERSCORES
- Prefix with project name: `APPNAME_CONFIG_PATH`

**Examples:**
```
PAIROOT_HOME=/custom/path
PAIROOT_API_KEY=...
DATABASE_URL=postgresql://...
```

## Code Licensing

**When applicable:** Open-source projects

**Common choices:**
- **MIT**: Permissive, minimal restrictions, most popular
- **Apache 2.0**: Permissive with explicit patent grant
- **GPL v3**: Copyleft, requires derivative works to be open-source
- **BSD 3-Clause**: Similar to MIT, slightly different wording
- **Unlicense**: No restrictions, public domain

**Best practice:** Include a LICENSE file at project root and mention it in README.

## Documentation Standards

### README

**Standard sections:**
1. Title and tagline
2. What is this?
3. Philosophy (optional but recommended)
4. Core principles
5. Architecture
6. MVP features
7. Tech stack
8. Open questions (if applicable)
9. Development status

### CLAUDE.md

**Standard sections:**
1. What this is
2. Tech stack
3. Directory layout
4. Architecture decisions
5. MVP scope
6. Code style
7. Standards and conventions
8. Repository info

### ROADMAP

**Standard structure:**
- Phases (Phase 1: Foundation, etc.)
- Items within phases
- Suggested build order / critical path

## Security Standards

### API Security

- **Authentication**: Use tokens (JWT, API keys) or OAuth
- **HTTPS only**: Never plain HTTP for production
- **CORS**: Set explicitly, don't allow `*` if not needed
- **Input validation**: Validate and sanitize all inputs
- **Rate limiting**: Protect against abuse

### Secrets Management

- **Never commit secrets** to version control
- **Use environment variables** for API keys, passwords
- **.gitignore** should exclude config files with secrets
- **Documentation** should show example `.env` files with dummy values

## Dependency Standards

### Semantic Versioning

**Format:** `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)

**Rules:**
- MAJOR: Breaking changes (increment and reset others to 0)
- MINOR: New features, backward compatible (increment and reset PATCH to 0)
- PATCH: Bug fixes, backward compatible

**Example progression:** 1.0.0 → 1.1.0 → 1.1.1 → 2.0.0

### Dependency Management

- Use lock files (package-lock.json, go.sum, Pipfile.lock, etc.)
- Document minimum versions required
- Regularly update dependencies
- Test after updates

## Deployment Standards

### Docker

**If using containers:**
- Use `.dockerignore` to exclude unnecessary files
- Use multi-stage builds for optimization
- Don't run as root
- Use specific base image versions (not `latest`)

### Environment Parity

- Development, staging, and production should be as similar as possible
- Use configuration management (environment variables, config files) to handle differences
- Document environment-specific setup

## Language-Specific Standards

### Go
- Standard project layout (https://github.com/golang-standards/project-layout)
- Go naming conventions (CamelCase, exported functions capitalized)
- `go fmt` for formatting
- `go vet` for common mistakes
- Conventional commits with scopes like `feat(pkg):`

### Python
- PEP 8 for style
- Type hints where helpful
- Docstrings for modules, classes, functions
- Use `pyproject.toml` or `setup.py` for packaging
- Virtual environments for development

### JavaScript/TypeScript
- Use consistent formatter (Prettier, eslint)
- Semantic versioning for packages
- Proper tsconfig for TypeScript projects
- Type safety where possible

## Checklist for Projects

When inception is complete, verify:

- [ ] README has a philosophy/principles section
- [ ] CLAUDE.md documents architecture decisions, not just tech stack
- [ ] ROADMAP has clear phases and critical path
- [ ] File paths follow XDG Base Directory Spec (if applicable)
- [ ] Timestamps use ISO 8601 format
- [ ] Git repo exists and will use Conventional Commits
- [ ] config/secrets excluded from version control (.gitignore)
- [ ] Exit codes documented (if applicable)
- [ ] License chosen and documented
- [ ] Documentation is in markdown (GFM)
- [ ] Example config files use YAML format
- [ ] Log files use JSONL format
- [ ] Any APIs follow OpenAI-compatible or REST standards
