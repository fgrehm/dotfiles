#!/bin/env bash
# Preserve payload files from the old managed Claude/Pi layout before chezmoi
# removes those source entries. Never touch session, transcript, credential, or
# other user data.
set -euo pipefail

AGENTS_DIR="$HOME/.agents"

copy_if_missing() {
  local src="$1" dest="$2"
  [ -e "$src" ] || return 0
  [ -e "$dest" ] || [ -L "$dest" ] && return 0
  mkdir -p "$(dirname "$dest")"
  cp -p -- "$src" "$dest"
}

# Former ~/.claude payload.
copy_if_missing "$HOME/.claude/statusline.sh" "$AGENTS_DIR/statusline.sh"
for style in "$HOME/.claude/output-styles"/*.md; do
  [ -e "$style" ] || continue
  copy_if_missing "$style" "$AGENTS_DIR/output-styles/$(basename "$style")"
done

# Former ~/.pi/agent payload.
copy_if_missing "$HOME/.pi/agent/ollama-cloud.json" "$AGENTS_DIR/pi/ollama-cloud.json"
copy_if_missing "$HOME/.pi/agent/web-search.json" "$AGENTS_DIR/pi/web-search.json"
for extension in "$HOME/.pi/agent/extensions"/*.ts; do
  [ -e "$extension" ] || continue
  copy_if_missing "$extension" "$AGENTS_DIR/pi/extensions/$(basename "$extension")"
done
