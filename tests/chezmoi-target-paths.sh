#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$root/recipes/omarchy/chezmoi"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
config="$tmp/empty.toml"
: >"$config"

assert_target_path() {
  local source_path="$1" expected="$2" actual
  if [[ ! -f $source_path ]]; then
    printf 'FAIL: missing chezmoi source file: %s\n' "$source_path" >&2
    exit 1
  fi
  actual=$(chezmoi --source "$source_dir" target-path "$source_path")
  if [[ $actual != "$expected" ]]; then
    printf 'FAIL: %s maps to %s, expected %s\n' "$source_path" "$actual" "$expected" >&2
    exit 1
  fi
}

assert_target_path \
  "$source_dir/private_dot_config/mise/create_config.toml" \
  "$HOME/.config/mise/config.toml"
assert_target_path \
  "$source_dir/private_dot_config/wip-backup/create_config.sh" \
  "$HOME/.config/wip-backup/config.sh"

omarchy_ignore="$tmp/omarchy-ignore"
chezmoi --config "$config" --source "$root" execute-template \
  --override-data '{"isOmarchy":true,"installVantaAgent":false}' \
  --file "$root/recipes/.recipeignore" >"$omarchy_ignore"
grep -Fxq 'agent-usage-snapshot' "$omarchy_ignore" || {
  printf 'FAIL: the Omarchy profile still deploys SSH-capable agent usage tooling\n' >&2
  exit 1
}
non_omarchy_ignore="$tmp/non-omarchy-ignore"
chezmoi --config "$config" --source "$root" execute-template \
  --override-data '{"isOmarchy":false,"installVantaAgent":false}' \
  --file "$root/recipes/.recipeignore" >"$non_omarchy_ignore"
if grep -Fxq 'agent-usage-snapshot' "$non_omarchy_ignore"; then
  printf 'FAIL: non-Omarchy recipe filtering unexpectedly changed\n' >&2
  exit 1
fi

printf 'PASS: chezmoi seeds and Omarchy recipe exclusions render as intended\n'
