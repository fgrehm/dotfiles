#!/bin/sh
set -eu

if ! command -v omarchy >/dev/null 2>&1; then
  printf '%s\n' "omarchy is required to enable fgrehm.pomodoro" >&2
  exit 1
fi

omarchy plugin enable fgrehm.pomodoro --section center
