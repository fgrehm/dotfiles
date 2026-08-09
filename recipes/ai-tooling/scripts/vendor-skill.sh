#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: vendor-skill.sh <github-url> [skill-name]

Download a third-party skill from GitHub into skills/.

Examples:
  ./vendor-skill.sh https://github.com/apollographql/skills/tree/main/skills/rust-best-practices
  ./vendor-skill.sh https://github.com/user/repo/tree/main/my-skill custom-name
  ./vendor-skill.sh https://github.com/user/humanizer/tree/main

Accepts GitHub URLs in these formats:
  https://github.com/<owner>/<repo>/tree/<ref>/<path>  (subdirectory)
  https://github.com/<owner>/<repo>/tree/<ref>          (repo root)

The skill name defaults to the last path component, or the repo name for root URLs.
EOF
  exit 1
}

[ "${1:-}" ] || usage

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/../chezmoi/private_dot_agents/skills" && pwd -P)"

url="$1"

# Parse GitHub URL
if [[ "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/(.+)$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repo="${BASH_REMATCH[2]}"
  ref="${BASH_REMATCH[3]}"
  path="${BASH_REMATCH[4]%/}"
elif [[ "$url" =~ ^https://github\.com/([^/]+)/([^/]+)/tree/([^/]+)/?$ ]]; then
  owner="${BASH_REMATCH[1]}"
  repo="${BASH_REMATCH[2]}"
  ref="${BASH_REMATCH[3]}"
  path=""
else
  echo "ERROR: URL must match https://github.com/<owner>/<repo>/tree/<ref>[/<path>]"
  exit 1
fi

skill_name="${2:-$(basename "${path:-$repo}")}"
dest="$SKILLS_DIR/$skill_name"

# Resolve ref to a commit SHA for pinning
sha="$(gh api "repos/$owner/$repo/commits/$ref" --jq '.sha')"
short_sha="${sha:0:12}"

echo "Source: $owner/$repo @ $short_sha"
[ -n "$path" ] && echo "Path:   $path"
echo "Dest:   $dest"
echo ""

if [ -d "$dest" ]; then
  echo "Removing existing $dest"
  rm -rf "$dest"
fi

# Download the repo tarball and extract just the skill directory
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "Downloading..."
curl -sL \
  -H "Authorization: Bearer $(gh auth token)" \
  "https://api.github.com/repos/$owner/$repo/tarball/$sha" \
  -o "$tmpdir/archive.tar.gz"

# The tarball has a top-level dir like <owner>-<repo>-<sha>/
# Extract only the files under the skill path
# (pipefail disabled: head closes the pipe early, causing SIGPIPE in tar)
prefix="$(
  set +o pipefail
  tar -tzf "$tmpdir/archive.tar.gz" | head -1 | cut -d/ -f1
)"

if [ -n "$path" ]; then
  tar -xzf "$tmpdir/archive.tar.gz" -C "$tmpdir" "$prefix/$path/"
  extracted="$tmpdir/$prefix/$path"
else
  tar -xzf "$tmpdir/archive.tar.gz" -C "$tmpdir"
  extracted="$tmpdir/$prefix"
fi

mkdir -p "$dest"

# Keep only SKILL.md, README.md, and subdirectories
for item in "$extracted"/*; do
  name="$(basename "$item")"
  if [ -d "$item" ]; then
    mv "$item" "$dest/"
  elif [ "$name" = "SKILL.md" ] || [ "$name" = "README.md" ]; then
    mv "$item" "$dest/"
  fi
done

# Append source attribution to README.md
source_url="https://github.com/$owner/$repo/tree/$sha${path:+/$path}"
if [ -f "$dest/README.md" ]; then
  printf 'Source: %s\n\n---\n\n' "$source_url" | cat - "$dest/README.md" >"$tmpdir/README.md"
  mv "$tmpdir/README.md" "$dest/README.md"
else
  cat >"$dest/README.md" <<EOF
# $skill_name

Source: $source_url
EOF
fi

echo ""
echo "Vendored $skill_name from $owner/$repo"
echo "  commit: $sha"
echo "  url:    $source_url"
