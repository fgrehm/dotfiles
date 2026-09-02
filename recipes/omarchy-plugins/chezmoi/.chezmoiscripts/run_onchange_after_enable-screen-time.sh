#!/bin/sh
set -eu

if ! command -v omarchy >/dev/null 2>&1; then
  printf '%s\n' "omarchy is required to enable agx.screen-time" >&2
  exit 1
fi

omarchy plugin enable agx.screen-time
