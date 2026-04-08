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

- Scripts source `$CHEZMOI_SOURCE_DIR/scripts/ui.bash` for logging helpers
  (`log_info`, `log_skip`, `log_error`, `run_quiet`). This file is added by
  `chezmoi-recipes overlay` into `compiled-home/scripts/`. It is NOT missing
  from the repo -- do not suggest inlining these functions or adding fallback
  definitions.
- 2-space indentation, validated by `shfmt` and `shellcheck` (`make check`).
- `.sh.tmpl` files must have custom delimiters:
  `# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"`.
- `.sh.tmpl` files must have a vim modeline: `# vim: ft=bash.gotmpl` (line 2).
- Plain `.sh` files (no template directives) must have: `# vim: ft=bash`.
- **Critical: scripts that use template directives (`# {{ if ... }}`, `# {{
  include ... }}`, template variables like `.isContainer`, `.chezmoi.username`)
  MUST have `.sh.tmpl` extension.** Without `.tmpl`, chezmoi treats the file as
  plain shell and template directives become inert comments. This causes guards
  like `# {{ if .isContainer }}` to silently fail (the guarded code always
  runs). Flag any `.sh` file containing `# {{` as a bug.

## GitHub Binary Installs

- Use `.chezmoiexternals/<tool>.toml` instead of shell scripts for GitHub
  release tarballs. Files are always rendered as templates (no `.tmpl` needed).
- Pin versions explicitly with `{{- $version := "x.y.z" -}}`. Do NOT use
  `gitHubLatestReleaseAssetURL` or `gitHubLatestRelease` -- they make GitHub
  API calls that break unit tests.
- Always add `checksum.sha256 = "<hex>"` with the SHA-256 of the amd64 asset.
  Do NOT use `checksum.sha256url` -- an attacker can modify both the asset and
  the remote checksums file in the same release. The hardcoded value in this
  repo is the trust anchor. Get it with `sha256sum` on the downloaded file.
- No arch conditionals -- this repo is amd64 only. Hardcode `amd64`/`x86_64`
  directly in URLs.
- Add `# vim: ft=toml.gotmpl` as the **last line** of each `.toml` file.
  Putting it first breaks Go template whitespace trimming.
- Install scripts guard with `command -v` for idempotency, then `set -eo pipefail`
  at the top level. Hard-fail on any error -- a script that exits 0 after failure
  is silently marked done by chezmoi and requires `chezmoi state delete` to retry.
  Hard-failing lets `chezmoi apply` retry automatically on the next run.
  Use unquoted `$SUDO` (not `"$SUDO"`) to avoid empty-string command errors as root.
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

## .chezmoiignore target names for scripts

chezmoi strips the run-type prefix and `.tmpl` extension when computing the
target name used in `.chezmoiignore`. Do **not** flag existing ignore entries
as wrong just because the source filename has a prefix. Examples:

| Source filename | `.chezmoiignore` pattern |
|---|---|
| `run_once_install-ollama.sh` | `.chezmoiscripts/install-ollama.sh` |
| `run_once_after_install-pi-agent.sh` | `.chezmoiscripts/install-pi-agent.sh` |
| `run_onchange_after_enable-cartage.sh` | `.chezmoiscripts/enable-cartage.sh` |
| `run_onchange_after_install-mise-tools.sh` | `.chezmoiscripts/install-mise-tools.sh` |

The pattern `.chezmoiscripts/install-ollama.sh` correctly skips
`run_once_install-ollama.sh`. Suggesting it should be changed to
`run_once_install-ollama.sh` is incorrect.

## Testing

- Every recipe needs `test/unit/<recipe>.bats` (file deployment checks).
- Recipes with install scripts need `test/e2e/<recipe>.bats` (binary on PATH,
  idempotency).
- Tests run in the devcontainer, never on the host.
