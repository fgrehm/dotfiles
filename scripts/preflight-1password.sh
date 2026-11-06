#!/usr/bin/env bash
set -euo pipefail

if ! command -v op >/dev/null 2>&1; then
  printf 'Preflight failed: 1Password CLI (`op`) is not installed.\n' >&2
  printf 'On Omarchy, install it with Install > Service > 1Password, then rerun this check.\n' >&2
  exit 1
fi

if ! op vault list --format=json >/dev/null; then
  printf 'Preflight failed: `op` cannot access a signed-in 1Password account.\n' >&2
  printf 'Unlock 1Password and enable CLI integration in Settings > Developer, then rerun this check.\n' >&2
  exit 1
fi

printf 'Preflight passed: `op` is installed and can access 1Password vaults.\n'
