# Copilot Instructions

This is a chezmoi dotfiles repo using
[chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes) for modular
organization. `chezmoi-recipes overlay` merges `home/` and `recipes/*/chezmoi/`
into `compiled-home/` (the chezmoi source state). Each file belongs to exactly
one recipe or `home/`, never both. See [CLAUDE.md](../CLAUDE.md) for full
project context.

Key points for reviews:

## Structure

- Files live in `home/` (shared) or `recipes/<name>/chezmoi/` (modular), never
  in `compiled-home/` (generated).
- Each recipe has a `README.md` and a `chezmoi/` subdirectory.

## Shell Scripts

- 2-space indentation, validated by `shfmt` and `shellcheck` (`make check`).
- `.sh.tmpl` files must have custom delimiters:
  `# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"`.
- `.sh.tmpl` files must have a vim modeline: `# vim: ft=bash.gotmpl` (line 2).
- Plain `.sh` files (no template directives) must have: `# vim: ft=bash`.

## GitHub Binary Installs

- Use `.chezmoiexternals/<tool>.toml` instead of shell scripts for GitHub
  release tarballs. Files are always rendered as templates (no `.tmpl` needed).
- Pin versions explicitly with `{{- $version := "x.y.z" -}}`. Do NOT use
  `gitHubLatestReleaseAssetURL` or `gitHubLatestRelease` -- they make GitHub
  API calls that break unit tests.
- Add `# vim: ft=toml.gotmpl` as the **last line** of each `.toml` file.
  Putting it first breaks Go template whitespace trimming.
- Install scripts guard with `command -v`, use `set -eo pipefail` inside `_install()`
  only, and fail gracefully (don't block `chezmoi apply`).
- Completion scripts (`run_onchange_after_completions-*.sh.tmpl`) must NOT use
  `set -euo pipefail` at the top level. Wrap each generation call in `if !` so a
  transient failure doesn't block `chezmoi apply`. Always prepend
  `export PATH="$HOME/.local/bin:$PATH"` so freshly installed binaries are
  discoverable during apply.
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
