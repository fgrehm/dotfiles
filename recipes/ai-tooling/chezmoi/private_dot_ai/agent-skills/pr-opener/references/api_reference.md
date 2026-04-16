# GitHub CLI Reference for PR Opener

Quick reference for `gh` commands used in PR creation workflows.

## gh pr create

Opens a pull request.

**Syntax:**
```bash
gh pr create [flags]
```

**Common Flags:**

| Flag | Description | Example |
|------|-------------|---------|
| `--title` | Title for the PR (required unless interactive) | `--title "Fix login timeout"` |
| `--body` | Description/body text | `--body "Fixes #123 by..."` |
| `--draft` | Create as draft (not ready for review) | `--draft` |
| `--base` | Target branch (default: main) | `--base origin/main` |
| `--head` | Source branch (default: current) | `--head feature/auth` |
| `--reviewer` | Request reviewer | `--reviewer @username` |
| `--assignee` | Assign to user | `--assignee @username` |
| `--label` | Add labels | `--label "bug,urgent"` |

**Example:**
```bash
gh pr create --draft \
  --title "Fix login timeout" \
  --body "Resolves issue with session expiring too quickly" \
  --base origin/main \
  --head feature/auth \
  --reviewer @alice
```

## gh pr view

View PR details.

```bash
gh pr view [number]  # View specific PR
gh pr view           # View PR for current branch
```

## PR Template Format

GitHub repos commonly include `.github/pull_request_template.md` with suggested structure:

```markdown
## Description
Brief summary of changes

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change

## Testing
Steps to verify the changes

## Checklist
- [ ] Tests pass
- [ ] Docs updated
```

When this template exists, the PR opener skill reads it and includes it in the proposal for reference.

## Best Practices for PR Descriptions

1. **Lead with the "why"**: Explain the problem before the solution
2. **Reference related issues**: Use `Fixes #123` or `Related to #456`
3. **Include testing notes**: How should this be tested?
4. **Keep it concise**: Aim for clarity over verbosity
5. **Separate concerns**: One logical change per PR when possible
