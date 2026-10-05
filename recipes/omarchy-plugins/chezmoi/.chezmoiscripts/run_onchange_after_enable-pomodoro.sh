#!/bin/sh
set -eu

plugin="fgrehm.pomodoro"
section="center"

if ! command -v omarchy >/dev/null 2>&1; then
  printf '%s\n' "omarchy is required to enable $plugin" >&2
  exit 1
fi

# Skip the reload when the plugin is already on. A failing check (older omarchy
# without `plugin list --json`, no jq) falls through to enabling it as before.
if omarchy plugin list --json 2>/dev/null |
  jq -e --arg id "$plugin" 'any(.[]; .id == $id and .enabled)' >/dev/null 2>&1; then
  printf '%s\n' "$plugin is already enabled, skipping" >&2
  exit 0
fi

omarchy plugin enable "$plugin" --section "$section"
