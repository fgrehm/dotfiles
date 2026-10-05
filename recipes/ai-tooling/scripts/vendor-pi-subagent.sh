#!/usr/bin/env bash
# Vendor Pi's subagent extension example into this recipe.
#
# Upstream: https://github.com/earendil-works/pi
# Path:     packages/coding-agent/examples/extensions/subagent
#
# Never edit the vendored files by hand. Re-run this script instead, and commit
# whatever it reports, including the sha bump in VENDOR.md.

set -euo pipefail

REPO="earendil-works/pi"
PATH_IN_REPO="packages/coding-agent/examples/extensions/subagent"
UPSTREAM_URL="https://github.com/$REPO/blob/main/$PATH_IN_REPO"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DEST="$(cd "$SCRIPT_DIR/../chezmoi/private_dot_agents/pi/extensions/subagent" && pwd -P)"
VENDOR_MD="$DEST/VENDOR.md"

usage() {
  cat <<'EOF'
Usage: vendor-pi-subagent.sh [--sha <commit>] [--check]

  --sha <commit>   Vendor a specific upstream commit (default: HEAD of the path).
  --check          Report whether upstream moved since the vendored sha. Exits
                   1 when the example changed and re-vendoring is needed.

Examples:
  ./vendor-pi-subagent.sh --check
  ./vendor-pi-subagent.sh
  ./vendor-pi-subagent.sh --sha 8af7690c4f0c41fad274620829c75a3243d07aa3
EOF
  exit 1
}

check_only=0
sha=""
while [ $# -gt 0 ]; do
  case "$1" in
  --sha)
    sha="${2:-}"
    [ -n "$sha" ] || usage
    shift 2
    ;;
  --check)
    check_only=1
    shift
    ;;
  -h | --help) usage ;;
  *) usage ;;
  esac
done

command -v gh >/dev/null 2>&1 || {
  echo "ERROR: gh is required" >&2
  exit 1
}

# The vendored sha lives in VENDOR.md, so a re-vendor can report the delta.
vendored_sha() {
  sed -n 's/^| Commit | `\([0-9a-f]*\)` |$/\1/p' "$VENDOR_MD" | head -1
}

latest_sha="$(gh api "repos/$REPO/commits?path=$PATH_IN_REPO&per_page=1" --jq '.[0].sha')"

if [ -z "$sha" ]; then
  sha="$latest_sha"
fi

current_sha="$(vendored_sha || true)"

if [ "$check_only" -eq 1 ]; then
  echo "vendored: ${current_sha:-<none>}"
  echo "upstream: $latest_sha"
  if [ "$current_sha" = "$latest_sha" ]; then
    echo "OK: vendored copy matches upstream HEAD of the path"
    exit 0
  fi
  echo "STALE: re-run vendor-pi-subagent.sh (no arguments) to update" >&2
  exit 1
fi

echo "Source: $REPO @ $sha"
echo "Path:   $PATH_IN_REPO"
echo "Dest:   $DEST"
echo

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "Downloading..."
curl -sL \
  -H "Authorization: Bearer $(gh auth token)" \
  "https://api.github.com/repos/$REPO/tarball/$sha" \
  -o "$tmpdir/archive.tar.gz"

# (pipefail disabled: head closes the pipe early, causing SIGPIPE in tar)
prefix="$(
  set +o pipefail
  tar -tzf "$tmpdir/archive.tar.gz" | head -1 | cut -d/ -f1
)"

tar -xzf "$tmpdir/archive.tar.gz" -C "$tmpdir" --strip-components=1 --wildcards "$prefix/$PATH_IN_REPO/*"
extracted="$tmpdir/$PATH_IN_REPO"

commit_date="$(gh api "repos/$REPO/commits/$sha" --jq '.commit.author.date')"
commit_subject="$(gh api "repos/$REPO/commits/$sha" --jq '.commit.message | split("\n")[0]')"

# Only the extension sources and its upstream README are vendored. The example's
# sample agents and prompt templates are intentionally dropped: we ship one
# generic agent instead (private_dot_agents/pi/agents/delegate.md), and the
# prompt templates only restate the chain ordering the model can infer.
for name in index.ts agents.ts README.md; do
  if [ ! -f "$extracted/$name" ]; then
    echo "ERROR: $name missing from upstream at $sha" >&2
    exit 1
  fi
  cp "$extracted/$name" "$DEST/$name"
done

# Preserve the previous sha so the diff is reviewable in VENDOR.md.
if [ -z "$current_sha" ]; then
  previous_line="none, first vendoring"
elif [ "$current_sha" != "$sha" ]; then
  previous_line="$current_sha"
else
  previous_line="none (unchanged)"
fi

cat >"$VENDOR_MD" <<EOF
# Vendored source

\`index.ts\` and \`agents.ts\` in this directory are copied verbatim from the Pi
coding agent repository. They are not maintained here.

| | |
|---|---|
| Upstream | <https://github.com/$REPO> |
| Path | \`$PATH_IN_REPO\` |
| Commit | \`$sha\` |
| Commit date | ${commit_date:0:10} |
| Commit message | \`$commit_subject\` |
| License | MIT, Copyright (c) 2025 Mario Zechner |
| Vendored on | $(date +%F) |
| Previous commit | $previous_line |
| Upstream URL | <$UPSTREAM_URL> |

\`README.md\` in this directory is the upstream README, kept unmodified so the
extension's own documentation stays available offline.

## Local modifications

None. Both files are byte-identical to upstream.

## Re-vendoring

Do not edit the files by hand. Re-run the vendoring helper, which resolves a
new upstream commit, reports the change, and rewrites this file:

\`\`\`sh
recipes/ai-tooling/scripts/vendor-pi-subagent.sh [--sha <commit>]
\`\`\`

Run it when upgrading Pi and check whether the example changed:

\`\`\`sh
recipes/ai-tooling/scripts/vendor-pi-subagent.sh --check
\`\`\`

## Why this is vendored

Pi ships this example as documentation, not as a supported package, so there is
nothing to install from. Vendoring it gives the \`subagent\` tool (single,
parallel, and chain dispatch to isolated child \`pi\` processes) without pulling in
\`pi-subagents\`, which adds a large dependency and a much larger feature surface
we do not use.

The vendored example expects agents in \`~/.pi/agent/agents/\`. This recipe ships
a single generic \`delegate\` agent; see the ai-tooling README.
EOF

echo
echo "Vendored $REPO $PATH_IN_REPO"
echo "  commit: $sha"
if [ -n "$current_sha" ]; then
  echo "  was:    $current_sha"
else
  echo "  was:    (none, first vendoring)"
fi
echo "  url:    $UPSTREAM_URL"
echo
echo "Next: run 'make check' (the vendored .ts files are excluded from Prettier)"
echo "      and review the diff before committing."
