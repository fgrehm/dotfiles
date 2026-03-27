#!/usr/bin/env bash
# Check pinned versions in .chezmoiexternals/*.toml files against GitHub latest releases.
# Usage: ./scripts/check-versions.sh [recipes-dir]
#
# Reads {{- $version := "x.y.z" -}} patterns from .toml files, extracts the
# GitHub owner/repo from the URL, and compares against the latest release tag.
#
# Auth (checked in order):
#   1. gh CLI (if installed and authenticated)
#   2. GITHUB_TOKEN env var (for CI)
#   3. Unauthenticated curl (60 req/hour rate limit)
#
# Requires: curl, grep (gh optional)

set -euo pipefail

recipes_dir="${1:-.}"

# Determine fetch strategy once at startup
fetch_mode="curl"
auth_header=()

if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  fetch_mode="gh"
elif [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_header=(-H "Authorization: token $GITHUB_TOKEN")
fi

check_count=0
behind_count=0
error_count=0

while read -r toml_file; do
  # Extract pinned version (first match)
  pinned=$(grep -oP '\$version\s*:=\s*"\K[^"]+' "$toml_file" 2>/dev/null || true)
  if [[ -z "$pinned" ]]; then
    continue
  fi

  # Extract GitHub owner/repo from URL
  repo=$(grep -oP 'github\.com/\K[^/]+/[^/]+' "$toml_file" 2>/dev/null | head -1 || true)
  if [[ -z "$repo" ]]; then
    continue
  fi

  tool=$(basename "$toml_file" .toml)
  check_count=$((check_count + 1))

  # Fetch latest release tag
  if [[ "$fetch_mode" == "gh" ]]; then
    latest=$(gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null || true)
  else
    latest=$(curl -fsSL "${auth_header[@]}" \
      "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
      | grep -oP '"tag_name"\s*:\s*"\K[^"]+' || true)
  fi

  if [[ -z "$latest" ]]; then
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "?" "ERROR: could not fetch latest from $repo"
    error_count=$((error_count + 1))
    continue
  fi

  # Strip leading 'v' for comparison
  latest_clean="${latest#v}"

  if [[ "$pinned" == "$latest_clean" ]]; then
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "$latest_clean" "up to date"
  else
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "$latest_clean" "UPDATE AVAILABLE"
    behind_count=$((behind_count + 1))
  fi
done < <(find "$recipes_dir" -path '*/.chezmoiexternals/*.toml' -type f | sort)

if [[ $check_count -eq 0 ]]; then
  echo "No pinned versions found in $recipes_dir"
  exit 0
fi

echo ""
echo "Checked $check_count tool(s): $behind_count behind, $error_count error(s)"

if [[ $behind_count -gt 0 ]]; then
  exit 1
fi
