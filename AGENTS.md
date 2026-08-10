# AGENTS.md

Project context for AI assistants working on this repo.

## What This Is

A chezmoi dotfiles repo organized with [chezmoi-recipes](https://github.com/fgrehm/chezmoi-recipes). Target: Debian 13 (Trixie) laptops running KDE Plasma 6, and devcontainers/Codespaces.

> **Debian is still a supported bare-metal target** — one laptop still runs Debian 13. The ultimate goal is to migrate fully to Omarchy and drop Debian as bare-metal, keeping it for devcontainers/Codespaces. Recipes are adapted to Omarchy one at a time; Debian support is kept alongside until the transition is complete.

> **Omarchy support is a work in progress.** The current system is Omarchy (Arch-based, Hyprland). Detection (`isOmarchy`) and a guard that skips all recipes on Omarchy are in place; recipes are being adapted one at a time. Debian support is kept alongside it. See `OMARCHY.md` for the living status, follow-ups, and learnings.
>
> **Config philosophy:** only track a config in the repo when there's a need to customize it; otherwise let omarchy manage it (e.g. ghostty config is omarchy's default — we only handle install + default terminal).

> **Omarchy skill:** when working on omarchy-specific config, install scripts, or anything touching `~/.config/` on an Omarchy host, always load the `omarchy` skill (at `~/.pi/agent/skills/omarchy/SKILL.md`) if it's available. It covers the safe customization patterns, command discovery, and the read-only `~/.local/share/omarchy/` rule.

chezmoi-recipes adds a recipe layer on top of chezmoi: related config files and install scripts are grouped into self-contained directories under `recipes/`. Running `chezmoi-recipes overlay` merges `home/` and all `recipes/*/chezmoi/` fragments into `compiled-home/`, which chezmoi reads as its source state (via `.chezmoiroot`). A `read-source-state.pre` hook runs the overlay automatically before any chezmoi command. Each file must belong to exactly one recipe or `home/`, never both (overlapping files are an error). See the [chezmoi-recipes README](https://github.com/fgrehm/chezmoi-recipes) for more.

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
.devcontainer/        devcontainer config (Debian 13 + mise)
```

## Recipe Structure

A recipe is a directory under `recipes/` with a `README.md` and a `chezmoi/` subdirectory. The `chezmoi/` contents use standard chezmoi naming (`dot_`, `private_`, `run_once_`, `.tmpl`, etc.) and get overlaid into `compiled-home/`.

## Agent Config Home (`~/.agents/`)

`~/.agents/` is the canonical cross-client home for agent config (the ecosystem convention). The `ai-tooling` recipe manages it:

- `~/.agents/AGENTS.md` — global agent instructions (canonical). `~/.pi/agent/AGENTS.md` and `~/.claude/CLAUDE.md` are symlinks to it, so both tools read the same rules.
- `~/.agents/skills/<name>/` — canonical skills home. A `run_onchange_after_link-skills.sh.tmpl` script creates individual per-agent symlinks (`~/.claude/skills/<name>`, `~/.pi/agent/skills/<name>`) and re-runs when the skill set changes (embedded hash). It only creates missing symlinks, so non-chezmoi entries coexist (e.g. the omarchy skill).

Do NOT use whole-directory symlinks for the per-agent skills dirs — that would clobber non-chezmoi entries (like the omarchy skill). Use the individual-symlink script instead.

## Directory Privacy Must Be Consistent Across Recipes

chezmoi maps `dot_config` and `private_dot_config` to the same target directory (`.config`) but with different permissions. If two recipes in the overlay use different privacy prefixes for the same target directory, chezmoi will refuse to apply with:

```
chezmoi: .config: inconsistent state (...dot_config, ...private_dot_config)
```

**Rule: all recipes that write under `.config` must use `private_dot_config`. Never use `dot_config` for `.config`.** The `.config` directory holds user application state and is private by convention. Mixing `dot_config` and `private_dot_config` across recipes is always a bug.

## Environment Detection

`.chezmoi.toml.tmpl` sets template data based on auto-detection:

| Variable | Source |
|----------|--------|
| `.name` | Prompted via `promptStringOnce` at `chezmoi init` |
| `.email` | Prompted via `promptStringOnce` at `chezmoi init` |
| `.onepasswordSshVault` | Prompted at `chezmoi init` (laptop only; empty string in containers) |
| `.onepasswordSshItem` | Prompted at `chezmoi init` (laptop only; empty string in containers) |
| `.isContainer` | `/.dockerenv`, `/run/.containerenv`, `CODESPACES`, etc. |
| `.isDebian` | `.chezmoi.osRelease.id == "debian"` |
| `.isOmarchy` | `omarchy` on PATH or `~/.local/share/omarchy` exists |
| `.useZsh` | `not .isOmarchy` (true on Debian, false on Omarchy); gates zsh install/completions |
| `.hasNvidiaGPU` | `lspci` output (skipped in containers) |

Use `{{ if .isContainer }}` in templates and `.chezmoiignore` for conditional deployment.

## chezmoi-recipes Integration

A `read-source-state.pre` hook runs `chezmoi-recipes overlay` before any chezmoi command that reads source state. Guard hooks block `chezmoi add`, `chezmoi edit`, etc. to prevent writing to the generated `compiled-home/`.

Edit files in `home/` or `recipes/`, never in `compiled-home/`.

### Skipping recipes conditionally

`recipes/.recipeignore` lists recipe names to skip during overlay. It is a Go template evaluated against chezmoi's rendered config data (the `[data]` section from `~/.config/chezmoi/chezmoi.toml`). Example:

```
{{- if .isContainer }}
laptop
{{- end }}
```

Use `.recipeignore` to exclude entire recipes (e.g. laptop-only tools) rather than adding `isContainer` guards inside individual scripts.

**Rule: any script that uses template directives (`# {{ if ... }}`, `# {{ include ... }}`, template variables) MUST have the `.sh.tmpl` extension.** Without `.tmpl`, chezmoi treats the file as a plain script and template directives become inert comments, causing guards like `# {{ if .isContainer }}` to silently fail (the guarded code always runs). Scripts with no template directives should use plain `.sh`.

## Code Style

- Shell scripts use 2-space indentation (`.editorconfig` / shfmt).
- `.sh.tmpl` files use custom template delimiters (`# {{` / `}}`) so shfmt and shellcheck can parse them as valid shell.
- All `.sh.tmpl` files need: `# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"`.
- Use `$SUDO` variable (set via template conditional) instead of inline template `sudo` conditionals.
- Run `make check` to lint (shfmt + shellcheck).
- Vim modelines: `# vim: ft=bash.gotmpl` on `.sh.tmpl` files (line 2, after shebang); `# vim: ft=toml.gotmpl` on `.chezmoiexternals/*.toml` files (last line -- putting it first breaks Go template trimming).

## GitHub Binary Installs

For tools distributed as GitHub release tarballs, use chezmoi's `.chezmoiexternals/` directory instead of a shell install script. Each recipe places a `<tool>.toml` file in `chezmoi/.chezmoiexternals/`. Files in this directory are always rendered as templates (no `.tmpl` extension needed).

```toml
# recipes/git/chezmoi/.chezmoiexternals/diffnav.toml
{{- $version := "1.2.3" -}}
[".local/bin/diffnav"]
  type = "archive-file"
  url = "https://github.com/dlvhdr/diffnav/releases/download/v{{ $version }}/diffnav_Linux_x86_64.tar.gz"
  executable = true
  path = "diffnav"
  checksum.sha256 = "<sha256 of the amd64 archive>"
# vim: ft=toml.gotmpl
```

For releases where the archive path contains the version:

```toml
{{- $version := "1.2.3" -}}
[".local/bin/tool"]
  type = "archive-file"
  url = "https://github.com/owner/repo/releases/download/v{{ $version }}/tool-{{ $version }}-x86_64-linux.tar.gz"
  path = "tool-{{ $version }}-x86_64-linux/tool"
  executable = true
  checksum.sha256 = "<sha256 of the amd64 archive>"
# vim: ft=toml.gotmpl
```

Pin versions explicitly -- do NOT use `gitHubLatestReleaseAssetURL` or `gitHubLatestRelease`. Those make GitHub API calls that may hit rate limits.

Always include `checksum.sha256` with the SHA-256 of the downloaded archive or file (amd64 only -- no arch conditionals). Do NOT use `checksum.sha256url` pointing at the project's checksums file: an attacker who compromises a release can modify both the asset and the checksums file. The hardcoded value in this repo is the trust anchor. To get the hash, download the asset and run `sha256sum` on it, or find it in the project's `checksums.txt` at release time and copy the value here.

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

set -eo pipefail

log_info "Installing <tool>..."
run_quiet $SUDO apt-get update -qq
run_quiet $SUDO apt-get install -y <tool>
```

Key points:
- Guard with `command -v` for idempotency.
- `set -eo pipefail` at the top level (after guards and variable setup) -- hard fail on any error so chezmoi does not mark the script as completed. This lets `chezmoi apply` retry the script on the next run without needing to manipulate chezmoi state. A script that exits 0 after a failure would be silently marked done and require `chezmoi state delete` to retry.
- Use unquoted `$SUDO` (not `"$SUDO"`) -- quoting expands to an empty-string command when running as root.
- **On Omarchy, `omarchy` commands handle sudo internally** (`omarchy pkg add`, `omarchy install`, ... declare `requires-sudo=true` and call `sudo` themselves). Do NOT prefix `$SUDO` -- sudo can't find `omarchy` in its restricted PATH (`~/.local/share/omarchy/bin/` is user-local). Call `omarchy ...` directly.

## Completion Scripts

Completion scripts (`run_onchange_after_completions-*.sh.tmpl`) are non-essential and must never block `chezmoi apply`. Do NOT use `set -euo pipefail` at the top level. Instead, wrap each generation command in an `if !` block:

```bash
#!/bin/env bash
# vim: ft=bash.gotmpl
# chezmoi:template:left-delimiter="# {{" right-delimiter="}}"
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

export PATH="$HOME/.local/bin:$PATH"

if ! command -v <tool> &>/dev/null; then
  log_skip "<tool> not found, skipping completions"
  exit 0
fi

BASH_DIR="$HOME/.local/share/bash-completion/completions"
ZSH_DIR="$HOME/.zsh/completions"
mkdir -p "$BASH_DIR" "$ZSH_DIR"

log_info "Generating <tool> completions..."
if ! <tool> completion bash >"$BASH_DIR/<tool>"; then
  log_error "Failed to generate <tool> bash completions (non-fatal)"
fi
if ! <tool> completion zsh >"$ZSH_DIR/_<tool>"; then
  log_error "Failed to generate <tool> zsh completions (non-fatal)"
fi
```

Key points: prepend `$HOME/.local/bin` to PATH so freshly installed binaries are discoverable during `chezmoi apply`; no `set -euo pipefail`; `if !` per command.

## Script Ordering

chezmoi runs scripts in two phases, sorted lexicographically within each:

1. **Before file deployment**: `run_once_`, `run_onchange_`, `run_once_before_`, `run_onchange_before_` scripts
2. **After file deployment**: `run_once_after_`, `run_onchange_after_` scripts

Use `run_once_after_` or `run_onchange_after_` when a script depends on files deployed by chezmoi (e.g., a tool installed via a config file that lands during file deployment).

## Conditional File Skipping

Two mechanisms for environment-conditional deployment:

- **`.chezmoiignore`** in a recipe's `chezmoi/` dir: skip target files by environment. Patterns match target paths (e.g., `.config/mise/config.toml`). Uses chezmoi template syntax (`{{ if .isContainer }}`). For scripts, the pattern matches the target path with the `run_`/`once_`/`onchange_`/`before_`/`after_` attributes stripped. So `run_once_after_install-pi-agent.sh` is matched by `.chezmoiscripts/install-pi-agent.sh` (not by its full source name).
- **Template guards** inside scripts: early `exit 0` based on template conditionals. Use for `run_onchange_` scripts that can't be skipped via `.chezmoiignore`.

## Config-Triggered Re-runs

`run_onchange_` scripts re-run when their rendered content changes. To re-trigger when a deployed config file changes, embed its hash in a comment:

```bash
# config hash: # {{ include "private_dot_config/mise/config.toml" | sha256sum }}
```

## Dangerous Commands

Never run `chezmoi apply` on the host from this assistant. Only run it inside a container. Safe on host: `chezmoi diff`, `make check`, `git diff`.
