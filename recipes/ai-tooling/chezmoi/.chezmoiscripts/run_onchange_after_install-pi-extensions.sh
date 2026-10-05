#!/usr/bin/env bash
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

# Managed packages and the oldest version we are happy with. These are floors, not
# pins: a machine behind a floor gets the newest release, so machines seeded by
# another manager (a VM image seed) and machines maintained by hand both move
# forward instead of ping-ponging over a fixed version.
declare -A floor=(
  ["pi-web-access"]=0.36.0
  ["pi-ollama-cloud"]=0.12.2
)

newer_than() { # <candidate> <installed> -> 0 when candidate > installed
  [ -z "$2" ] && return 0
  [ "$1" = "$2" ] && return 1
  [ "$(printf '%s\n' "$2" "$1" | sort -V | tail -n 1)" = "$1" ]
}

# Drop the version pin from a managed package's settings entry, keeping every
# other key and every other package untouched. A pinned entry never moves, not
# even through `pi update --extensions`, so freeing it here is what lets the
# machine track new releases. Installs below are unpinned, so it stays unpinned.
unpin() { # <name>
  local tmp
  tmp="$(mktemp)"
  if ! jq --arg name "$1" '
    if .packages then
      .packages |= map(
        (if type == "object" then .source else . end) as $src
        | ($src | capture("^npm:(?<n>.+)@(?<v>[^@]+)$") // null) as $m
        | if $m != null and $m.n == $name
          then (if type == "object"
            then .source |= sub("@[^@]+$"; "")
            else sub("@[^@]+$"; "")
          end)
          else . end)
    else . end' "$settings" >"$tmp" 2>/dev/null; then
    rm -f "$tmp"
    log_error "Failed to read Pi package settings (leaving them alone)"
    return 1
  fi
  if cmp -s "$tmp" "$settings"; then
    rm -f "$tmp"
  else
    mv "$tmp" "$settings"
    log_info "Removed version pin from Pi package: $1"
  fi
}

# Installed versions come from the paths `pi list` reports, not from the settings
# entries: an unpinned entry carries no version to read, and that is the normal
# case here. `pi list` prints two indented lines per package, the source and then
# its install path.
declare -A installed=()
while IFS=$'\t' read -r name version; do
  [ -n "$name" ] && installed["$name"]="$version"
done < <(
  pi list 2>/dev/null | awk '
    /^[[:space:]]+(npm:|git:|file:)[^[:space:]]*$/ {
      name = $1
      sub(/@[0-9][^@]*$/, "", name)
      sub(/^[a-z]+:/, "", name)
      sub(/^@/, "", name)
      next
    }
    name != "" && $1 ~ /^\// { print name "\t" $1; name = "" }
  ' |
    while IFS=$'\t' read -r name path; do
      [ -f "$path/package.json" ] &&
        printf '%s\t%s\n' "$name" \
          "$(jq -r '.version // empty' "$path/package.json" 2>/dev/null)"
    done
)

for name in "${!floor[@]}"; do
  min="${floor[$name]}"
  current="${installed[$name]}"

  # Free any pin first: an entry pinned to a version never moves, not even
  # through `pi update --extensions`.
  [ -f "$settings" ] && unpin "$name"

  if [ -n "$current" ] && ! newer_than "$min" "$current"; then
    log_skip "Pi extension at or above floor: $name $current"
    continue
  fi

  # @latest, not a bare install: Pi records the installed version as a caret
  # range in ~/.pi/agent/npm, so `pi install npm:$name` on a machine below the
  # floor resolves to the range already on disk and stays where it is. @latest
  # rewrites the range to the new version, which is what makes later
  # `pi update --extensions` work again.
  log_info "Updating Pi extension: npm:$name@latest (floor $min, found ${current:-nothing})"
  if pi install "npm:$name@latest"; then
    # The install writes the `@latest` spec back into the settings entry.
    unpin "$name"
  else
    log_error "Failed to install Pi extension: npm:$name@latest (non-fatal)"
  fi
done
