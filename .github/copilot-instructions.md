# Copilot Instructions

This is a chezmoi dotfiles repo. See [CLAUDE.md](../CLAUDE.md) for full project
context, conventions, and patterns. Key points for reviews:

## Structure

- Files live in `home/` (shared) or `recipes/<name>/chezmoi/` (modular), never
  in `compiled-home/` (generated).
- Each recipe has a `README.md` and a `chezmoi/` subdirectory.

## Shell Scripts

- 2-space indentation, validated by `shfmt` and `shellcheck` (`make check`).
- `.sh.tmpl` files must have custom delimiters:
  `# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"`.
- `.sh.tmpl` files must have a vim modeline: `# vim: ft=bash.gotmpl`.
- Plain `.sh` files (no template directives) must have: `# vim: ft=bash`.
- Install scripts guard with `command -v`, use `set -e` inside `_install()`
  only, and fail gracefully (don't block `chezmoi apply`).
- Use `wget` instead of `curl` (curl not guaranteed on Debian).

## Script Ordering

- `run_once_` and `run_once_before_` run before file deployment.
- `run_once_after_` and `run_onchange_after_` run after file deployment.
- Within each phase, scripts are sorted lexicographically by full filename.
- Use `run_onchange_` with a hash comment to re-trigger on config changes.

## Environment

- `.isContainer` distinguishes containers from laptops.
- Use `.chezmoiignore` or `.recipeignore` to skip files/recipes by environment.
- camelCase for template variables.

## Testing

- Every recipe needs `test/unit/<recipe>.bats` (file deployment checks).
- Recipes with install scripts need `test/e2e/<recipe>.bats` (binary on PATH,
  idempotency).
- Tests run in the devcontainer, never on the host.
