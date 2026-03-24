# CLAUDE.md

Project context for AI assistants working on this repo.

## What This Is

A chezmoi dotfiles repo organized with
[chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). Target: Debian 13
(Trixie) laptops and devcontainers/Codespaces.

chezmoi-recipes adds a recipe layer on top of chezmoi: related config files and
install scripts are grouped into self-contained directories under `recipes/`.
Running `chezmoi-recipes overlay` merges `home/` and all `recipes/*/chezmoi/`
fragments into `compiled-home/`, which chezmoi reads as its source state (via
`.chezmoiroot`). A `read-source-state.pre` hook runs the overlay automatically
before any chezmoi command. Each file must belong to exactly one recipe or
`home/`, never both (overlapping files are an error). See the
[chezmoi-recipes README](https://github.com/fgrehm/chezmoi-recipes) for more.

## Repo Layout

```
.chezmoiroot          points chezmoi at compiled-home/
home/                 shared chezmoi source files (.chezmoi.toml.tmpl, etc.)
recipes/              modular recipe directories
  .recipeignore       optional, skips recipes by name (Go template, uses .isContainer etc.)
  <name>/
    README.md         required (discovery marker)
    chezmoi/          chezmoi source fragment (dot_*, .chezmoiscripts/, etc.)
compiled-home/        generated, gitignored
test/unit/            bats unit tests (file deployment)
test/e2e/             bats e2e tests (full apply with installs)
.devcontainer/        devcontainer config (Debian 13 + mise)
```

## Recipe Structure

A recipe is a directory under `recipes/` with a `README.md` and a `chezmoi/`
subdirectory. The `chezmoi/` contents use standard chezmoi naming (`dot_`,
`private_`, `run_once_`, `.tmpl`, etc.) and get overlaid into `compiled-home/`.

## Directory Privacy Must Be Consistent Across Recipes

chezmoi maps `dot_config` and `private_dot_config` to the same target directory
(`.config`) but with different permissions. If two recipes in the overlay use
different privacy prefixes for the same target directory, chezmoi will refuse to
apply with:

```
chezmoi: .config: inconsistent state (...dot_config, ...private_dot_config)
```

**Rule: all recipes that write under `.config` must use `private_dot_config`.
Never use `dot_config` for `.config`.** The `.config` directory holds user
application state and is private by convention. Mixing `dot_config` and
`private_dot_config` across recipes is always a bug.

This is caught by `test/unit/basics.bats` ("overlay fails when recipes mix
dot_config and private_dot_config for the same target").

## Environment Detection

`.chezmoi.toml.tmpl` sets template data based on auto-detection:

| Variable | Source |
|----------|--------|
| `.name` | Prompted via `promptStringOnce` at `chezmoi init` |
| `.email` | Prompted via `promptStringOnce` at `chezmoi init` |
| `.isContainer` | `/.dockerenv`, `/run/.containerenv`, `CODESPACES`, etc. |
| `.isDebian` | `.chezmoi.osRelease.id == "debian"` |
| `.hasNvidiaGPU` | `lspci` output (skipped in containers) |

Use `{{ if .isContainer }}` in templates and `.chezmoiignore` for conditional
deployment.

## chezmoi-recipes Integration

A `read-source-state.pre` hook runs `chezmoi-recipes overlay` before any chezmoi
command that reads source state. Guard hooks block `chezmoi add`, `chezmoi edit`,
etc. to prevent writing to the generated `compiled-home/`.

Edit files in `home/` or `recipes/`, never in `compiled-home/`.

### Skipping recipes conditionally

`recipes/.recipeignore` lists recipe names to skip during overlay. It is a Go
template evaluated against chezmoi's rendered config data (the `[data]` section
from `~/.config/chezmoi/chezmoi.toml`). Example:

```
{{- if .isContainer }}
laptop
{{- end }}
```

Use `.recipeignore` to exclude entire recipes (e.g. laptop-only tools) rather
than adding `isContainer` guards inside individual scripts. Scripts that have no
template directives should use `.sh` extension (not `.sh.tmpl`).

## Code Style

- Shell scripts use 2-space indentation (`.editorconfig` / shfmt).
- `.sh.tmpl` files use custom template delimiters (`# {{` / `}}`) so shfmt and
  shellcheck can parse them as valid shell.
- All `.sh.tmpl` files need: `# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"`.
- Use `$SUDO` variable (set via template conditional) instead of inline template
  `sudo` conditionals.
- Run `make check` to lint (shfmt + shellcheck).

## GitHub Binary Installs

For tools distributed as GitHub release tarballs, use chezmoi's `.chezmoiexternals/` directory instead of a shell install script. Each recipe places a `<tool>.toml` file in `chezmoi/.chezmoiexternals/`. Files in this directory are always rendered as templates (no `.tmpl` extension needed).

```toml
# recipes/git/chezmoi/.chezmoiexternals/diffnav.toml
{{- $arch := .chezmoi.arch -}}
{{- if eq $arch "amd64" -}}{{- $arch = "x86_64" -}}{{- end -}}
[".local/bin/diffnav"]
  type = "archive-file"
  url = {{ gitHubLatestReleaseAssetURL "dlvhdr/diffnav" (printf "diffnav_Linux_%s.tar.gz" $arch) | quote }}
  executable = true
  path = "diffnav"
```

For releases with a version-prefixed directory inside the archive, use `gitHubLatestRelease` to get the version for `path`:

```toml
{{- $version := (gitHubLatestRelease "owner/repo").TagName | trimPrefix "v" -}}
[".local/bin/tool"]
  type = "archive-file"
  url = {{ gitHubLatestReleaseAssetURL "owner/repo" (printf "tool-%s-linux.tar.gz" $version) | quote }}
  path = {{ printf "tool-%s/tool" $version | quote }}
  executable = true
```

Multiple recipes can each contribute `.chezmoiexternals/*.toml` files without conflict since each file has a unique name. Use a shell install script only for apt packages, tools needing post-install setup, or standalone binaries (not archives).

## Script Patterns

Install scripts follow this pattern:

```bash
#!/bin/env bash
# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if command -v <tool> &>/dev/null; then
  log_skip "<tool> already installed"
  exit 0
fi

# {{ if ne .chezmoi.username "root" }}
SUDO="sudo"
# {{ else }}
SUDO=""
# {{ end }}

_install() {
  set -eo pipefail
  log_info "Installing <tool>..."
  "$SUDO" apt-get update -qq
  "$SUDO" apt-get install -y <tool>
}

if ! _install; then
  log_error "Failed to install <tool>"
  log_info "Run 'chezmoi apply' again after fixing the issue."
fi
```

Key points: guard with `command -v`, `set -eo pipefail` inside function only,
graceful failure (don't block the rest of `chezmoi apply`).

## Script Ordering

chezmoi runs scripts in two phases, sorted lexicographically within each:

1. **Before file deployment**: `run_once_`, `run_onchange_`, `run_once_before_`,
   `run_onchange_before_` scripts
2. **After file deployment**: `run_once_after_`, `run_onchange_after_` scripts

Use `run_once_after_` or `run_onchange_after_` when a script depends on files
deployed by chezmoi (e.g., a tool installed via a config file that lands during
file deployment).

## Conditional File Skipping

Two mechanisms for environment-conditional deployment:

- **`.chezmoiignore`** in a recipe's `chezmoi/` dir: skip target files by
  environment. Patterns match target paths (e.g., `.config/mise/config.toml`).
  Uses chezmoi template syntax (`{{ if .isContainer }}`).
- **Template guards** inside scripts: early `exit 0` based on template
  conditionals. Use for `run_onchange_` scripts that can't be skipped via
  `.chezmoiignore`.

## Config-Triggered Re-runs

`run_onchange_` scripts re-run when their rendered content changes. To re-trigger
when a deployed config file changes, embed its hash in a comment:

```bash
# config hash: # {{ include "private_dot_config/mise/config.toml" | sha256sum }}
```

## Testing

Tests run inside the devcontainer (or with `DOTFILES_E2E=1`).

```bash
make test       # unit tests (file deployment)
make test-e2e   # e2e tests (full apply with installs)
make check      # shfmt + shellcheck
```

**Every new recipe needs tests:**

- `test/unit/<recipe>.bats` — verifies files land in the right destinations
  using `chezmoi_apply_files` (`--exclude=scripts`, no installs run). Required
  for any recipe that deploys config files.
- `test/e2e/<recipe>.bats` — runs `chezmoi_apply_full` (scripts included),
  checks the binary is on `$PATH`, and verifies idempotency. Required for any
  recipe with install scripts that download binaries.

Look at existing tests in `test/unit/` and `test/e2e/` for examples before
writing new ones.

Test helper (`test/test_helper.bash`) provides:
- `setup_dotfiles_repo` - creates temp repo with chezmoi-recipes layout
- `write_minimal_config_template` - non-interactive config (no prompts)
- `add_recipe`, `add_home_file` - populate test fixtures
- `run_overlay` - run `chezmoi-recipes overlay`
- `isolate_home` - override HOME/XDG to temp dirs
- `chezmoi_init` - non-interactive `chezmoi init`

## Dangerous Commands

Never run `chezmoi apply` on the host from this assistant. Only run it inside a
container. Safe on host: `chezmoi diff`, `make check`, `git diff`.
