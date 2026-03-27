#!/usr/bin/env bash
# Check pinned versions against GitHub latest releases.
# Usage: ./scripts/check-versions.sh [recipes-dir]
#
# Scans for pinned versions in:
#   - .chezmoiexternals/*.toml  ({{- $version := "x.y.z" -}} pattern)
#   - .chezmoiscripts/*.sh*     (VERSION="x.y.z" + github.com URL)
#
# Also reports .chezmoiexternals/*.toml files using /latest/download/ URLs
# (no pinned version, shows latest available for awareness).
#
# Auth (checked in order):
#   1. gh CLI (if installed and authenticated)
#   2. GITHUB_TOKEN env var (for CI)
#   3. Unauthenticated wget/curl (60 req/hour rate limit)
#
# Requires: wget or curl, GNU grep with PCRE support (gh optional)

set -euo pipefail

recipes_dir="${1:-.}"

# Determine fetch strategy once at startup (prefer wget, fallback to curl)
fetch_mode=""
auth_header=()

if command -v gh &>/dev/null && gh auth status &>/dev/null; then
  fetch_mode="gh"
elif command -v wget &>/dev/null; then
  fetch_mode="wget"
elif command -v curl &>/dev/null; then
  fetch_mode="curl"
fi

if [[ -n "${GITHUB_TOKEN:-}" ]] && [[ "$fetch_mode" == "curl" ]]; then
  auth_header=(-H "Authorization: token $GITHUB_TOKEN")
fi

check_count=0
behind_count=0
error_count=0
unpinned_count=0

# Fetch the latest release tag for a GitHub repo.
# Usage: fetch_latest owner/repo
fetch_latest() {
  local repo="$1"
  local url="https://api.github.com/repos/$repo/releases/latest"

  if [[ "$fetch_mode" == "gh" ]]; then
    gh api "repos/$repo/releases/latest" --jq '.tag_name' 2>/dev/null || true
  elif [[ "$fetch_mode" == "wget" ]]; then
    wget -qO- "$url" 2>/dev/null | grep -oP '"tag_name"\s*:\s*"\K[^"]+' || true
  elif [[ "$fetch_mode" == "curl" ]]; then
    curl -fsSL "${auth_header[@]}" "$url" 2>/dev/null | grep -oP '"tag_name"\s*:\s*"\K[^"]+' || true
  else
    echo "ERROR: neither wget nor curl found" >&2
    return 1
  fi
}

# Compare a pinned version against the latest release.
# Usage: check_version tool pinned repo
check_version() {
  local tool="$1" pinned="$2" repo="$3"
  check_count=$((check_count + 1))

  local latest
  latest=$(fetch_latest "$repo")

  if [[ -z "$latest" ]]; then
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "?" "ERROR: could not fetch latest from $repo"
    error_count=$((error_count + 1))
    return
  fi

  local latest_clean="${latest#v}"

  if [[ "$pinned" == "$latest_clean" ]]; then
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "$latest_clean" "up to date"
  else
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "$pinned" "$latest_clean" "UPDATE AVAILABLE"
    behind_count=$((behind_count + 1))
  fi
}

# --- .chezmoiexternals/*.toml with pinned $version ---

while IFS= read -r toml_file; do
  pinned=$(grep -oP '\$version\s*:=\s*"\K[^"]+' "$toml_file" 2>/dev/null || true)
  repo=$(grep -oP 'github\.com/\K[^/]+/[^/]+' "$toml_file" 2>/dev/null | head -1 || true)
  tool=$(basename "$toml_file" .toml)

  if [[ -n "$pinned" && -n "$repo" ]]; then
    check_version "$tool" "$pinned" "$repo"
  elif [[ -z "$pinned" && -n "$repo" ]] && grep -q 'releases/latest/download/' "$toml_file"; then
    # No $version variable and uses /releases/latest/download/ URL
    latest=$(fetch_latest "$repo")
    latest_clean="${latest#v}"
    printf "  %-20s  %-12s  %-12s  %s\n" "$tool" "(latest)" "${latest_clean:--}" "not pinned"
    unpinned_count=$((unpinned_count + 1))
  fi
done < <(find "$recipes_dir" -path '*/.chezmoiexternals/*.toml' -type f | sort)

# --- Shell scripts with VERSION="x.y.z" + github.com URL ---

while IFS= read -r script_file; do
  pinned=$(grep -oP '^\s*VERSION\s*=\s*"\K[^"]+' "$script_file" 2>/dev/null || true)
  if [[ -z "$pinned" ]]; then
    continue
  fi

  repo=$(grep -oP 'github\.com/\K[^/]+/[^/]+' "$script_file" 2>/dev/null | head -1 || true)
  if [[ -z "$repo" ]]; then
    continue
  fi

  # Derive tool name from script filename (strip run_once_install- prefix and extensions)
  tool=$(basename "$script_file" | sed -E 's/^run_(once|onchange)_(before_|after_)?install-//; s/\.(sh|bash)(\.tmpl)?$//')
  check_version "$tool" "$pinned" "$repo"
done < <(find "$recipes_dir" -path '*/.chezmoiscripts/*' \( -name '*.sh' -o -name '*.sh.tmpl' -o -name '*.bash' -o -name '*.bash.tmpl' \) -type f | sort)

# --- Summary ---

if [[ $check_count -eq 0 && $unpinned_count -eq 0 ]]; then
  echo "No versions found in $recipes_dir"
  exit 0
fi

echo ""
summary="Checked $check_count pinned version(s): $behind_count behind, $error_count error(s)"
if [[ $unpinned_count -gt 0 ]]; then
  summary="$summary, $unpinned_count unpinned"
fi
echo "$summary"

if [[ $behind_count -gt 0 || $error_count -gt 0 ]]; then
  exit 1
fi
