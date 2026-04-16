---
name: repo-health-check
description: >
  Run a security and health audit on a GitHub repository using OpenSSF Scorecard.
  Analyzes results in context - a weekend CLI tool gets different priorities than a
  production service. Use this skill whenever the user mentions repo security, branch
  protection, security audit, scorecard, supply chain security, repo hardening,
  dependency pinning, or wants to check if their GitHub project follows security best
  practices. Also trigger when the user asks "is my repo secure?" or "what should I
  fix first?" about a GitHub repository.
---

# Repo Health Check

Run OpenSSF Scorecard against a GitHub repo, then interpret, prioritize, and fix findings based on the project's actual context - not one-size-fits-all rules.

## Prerequisites

- Docker must be available (the skill runs Scorecard via its official container image)
- The `gh` CLI must be authenticated (`gh auth status` should succeed)
- The repo must be hosted on GitHub

## Workflow

### Step 1: Resolve the target repo

Determine which repo to audit. In order of preference:

1. If the user specified a repo, use that
2. If you're inside a git repo, extract the GitHub remote:
   ```bash
   gh repo view --json nameWithOwner -q .nameWithOwner
   ```
3. Ask the user

### Step 2: Gather project context

Before running Scorecard, collect signals that determine how to prioritize findings.
Run these in parallel where possible:

```bash
# Basic repo metadata
gh repo view OWNER/REPO --json name,description,isPrivate,stargazerCount,forkCount,primaryLanguage,defaultBranchRef,repositoryTopics,isArchived,licenseInfo

# Dependency footprint (rough proxy for complexity)
find . -maxdepth 3 -name "package.json" -o -name "go.mod" -o -name "requirements.txt" \
  -o -name "Cargo.toml" -o -name "Gemfile" -o -name "pom.xml" -o -name "build.gradle" \
  2>/dev/null | head -20

# How active is it?
gh api repos/OWNER/REPO/stats/commit_activity --jq '[.[].total] | add' 2>/dev/null

# Does anyone depend on this?
gh api repos/OWNER/REPO --jq '.subscribers_count, .network_count' 2>/dev/null

# Lines of code (rough)
find . -type f \( -name "*.go" -o -name "*.py" -o -name "*.js" -o -name "*.ts" \
  -o -name "*.rs" -o -name "*.java" -o -name "*.rb" -o -name "*.c" -o -name "*.cpp" \) \
  -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" \
  | xargs wc -l 2>/dev/null | tail -1

# Is there CI?
ls -la .github/workflows/ 2>/dev/null
```

From these signals, classify the project into one of these tiers:

- **Hobby/experiment**: Private or <50 stars, single contributor, no dependents, <2k LOC
- **Active project**: Public, some stars/forks, a few contributors, has CI
- **Production/library**: Depended on by others, many stars/forks, active maintenance, published package

State the tier clearly to the user before presenting results. This tier drives prioritization in Step 4.

### Step 3: Run OpenSSF Scorecard

```bash
docker run --rm \
  -e GITHUB_AUTH_TOKEN="$(gh auth token)" \
  gcr.io/openssf/scorecard:stable \
  --repo=github.com/OWNER/REPO \
  --show-details \
  --format=json 2>/dev/null
```

If Docker is not available, check if `scorecard` CLI is installed locally and fall back to:
```bash
GITHUB_AUTH_TOKEN=$(gh auth token) scorecard --repo=github.com/OWNER/REPO --show-details --format=json
```

Save the JSON output for parsing. If the command fails, show the error and suggest common fixes (token permissions, Docker not running, etc).

### Step 4: Interpret and prioritize

Parse the JSON output. For each check, you have a name, score (0-10), reason, and details.

**Prioritization rules by project tier:**

#### Hobby/experiment — focus on hygiene only
Critical (fix now):
- Vulnerabilities (score < 7)
- Branch-Protection if repo is public (basic: prevent force push to main)

Suggest but don't push:
- Security-Policy (add a SECURITY.md)
- License

Skip entirely (tell the user why you're skipping):
- Signed-Releases, CII-Best-Practices, Fuzzing, SAST, Packaging, Contributors

#### Active project — secure the basics
Critical:
- Vulnerabilities
- Branch-Protection (require reviews, no force push)
- Pinned-Dependencies (at least CI actions)
- Token-Permissions
- Dangerous-Workflow

Important:
- Code-Review
- Security-Policy
- Dependency-Update-Tool
- License

Nice to have:
- SAST, Fuzzing, Signed-Releases

#### Production/library — full hardening
Everything matters. Prioritize by score (lowest first) and risk level.
Flag anything below 7 as needing attention. Flag anything below 5 as urgent.

**Output format:**

Present results as a prioritized summary:

```
## Repo Health: OWNER/REPO
**Project tier**: [tier] — [one-line justification]
**Overall score**: X.X/10

### 🔴 Fix now
- [Check name] (score: N/10): [plain-English explanation of what's wrong and why it matters for THIS project]

### 🟡 Should fix
- ...

### 🟢 Looks good
- ...

### ⏭️ Skipped (not relevant for this project tier)
- ...
```

### Step 5: Fix

For each item in "Fix now" and "Should fix", offer concrete fixes. Prefer the approach that requires the least change:

**Branch protection** — apply via gh CLI:
```bash
# Example: require PR reviews on main
gh api repos/OWNER/REPO/branches/main/protection -X PUT \
  -f "required_pull_request_reviews[required_approving_review_count]=1" \
  -f "enforce_admins=true" \
  -F "required_status_checks=null" \
  -F "restrictions=null"
```

**Security policy** — create SECURITY.md:
```bash
cat > SECURITY.md << 'EOF'
# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly.
Email: [OWNER_EMAIL] (or use GitHub's private vulnerability reporting).

Do NOT open a public issue for security vulnerabilities.
EOF
```

**Pinned dependencies** — for GitHub Actions, pin to commit SHAs instead of tags.
Show the user the specific lines in their workflow files and the replacement.

**Token permissions** — add top-level permissions block to workflow files:
```yaml
permissions:
  contents: read
```

**Dependency update tool** — add dependabot config:
```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
```

For each fix:
1. Show the user what will change
2. Ask for confirmation before modifying files
3. Apply the fix
4. If the fix is a file change, offer to create a commit

After applying fixes, offer to re-run Scorecard to verify improvements.

## Important notes

- Never store or echo the GitHub token in plain text in output. The `$(gh auth token)` subshell is intentional — it avoids the token appearing in shell history or logs.
- If a check returns score -1, it means the check couldn't run (e.g., not enough data). Note this to the user but don't treat it as a failure.
- Scorecard checks like Contributors and CII-Best-Practices are informational for most projects. Don't alarm users about them unless the project is tier 3 (production/library).
- Some checks require admin-level tokens to fully evaluate (e.g., branch protection details). If results look incomplete, mention this.
