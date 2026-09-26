#!/bin/env bash
# vim: ft=bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"

if ! command -v pi &>/dev/null; then
  log_skip "Pi not found, skipping Pi extensions"
  exit 0
fi

# Pi manages extension installation and settings itself. Keep these machine-local
# settings out of the chezmoi source while making the desired extensions available
# whenever Pi is present.
settings="$HOME/.pi/agent/settings.json"

# Never downgrade an extension that is already installed: machines whose home is
# seeded by another manager (a VM image seed) pin newer versions and re-apply
# them at every boot, so reinstalling our pin would ping-pong. Only install when
# the package is absent or older than our pin; otherwise leave it alone and let
# whichever manager pinned the installed version keep it.
newer_than() { # <candidate> <installed> -> 0 when candidate > installed
  [ "$1" = "$2" ] && return 1
  [ "$(printf '%s\n' "$2" "$1" | sort -V | tail -n 1)" = "$1" ]
}

# Build a name -> installed version map from the settings entries. Entries are
# either "npm:<name>@<version>" strings or objects carrying a "source" key.
declare -A installed=()
if [ -f "$settings" ]; then
  map_file="$(mktemp)"
  jq -r '
    .packages[]?
    | if type == "object" then .source else . end
    | select(startswith("npm:"))
    | .[4:]
    | if test("@[^@]+$")
      then capture("^(?<name>.+)@(?<version>[^@]+)$") | "\(.name)\t\(.version)"
      else . + "\t"
      end' "$settings" >"$map_file" 2>/dev/null
  while IFS=$'\t' read -r name version; do
    [ -n "$name" ] && installed["$name"]="$version"
  done <"$map_file"
  rm -f "$map_file"
fi

for extension in npm:pi-web-access@0.31.0 npm:pi-ollama-cloud@0.12.1; do
  name="${extension#npm:}"
  name="${name%@*}"
  pin="${extension##*@}"

  if [ -n "${installed[$name]+x}" ] && ! newer_than "$pin" "${installed[$name]}"; then
    log_skip "Pi extension up to date: $name ${installed[$name]}"
    continue
  fi

  log_info "Installing Pi extension: $extension"
  if ! pi install "$extension"; then
    log_error "Failed to install Pi extension: $extension (non-fatal)"
  fi
done
