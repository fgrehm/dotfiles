#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/scripts/preflight-1password.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
export PATH="$tmp/bin:/usr/bin:/bin"
export OP_LOG="$tmp/op.log"
cat >"$tmp/bin/op" <<'OP'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$OP_LOG"
[[ $* == 'vault list --format=json' ]] || exit 2
[[ ${OP_FAIL:-0} == 0 ]]
OP
chmod +x "$tmp/bin/op"

"$script" | grep -Fq 'Preflight passed'
grep -Fqx 'vault list --format=json' "$OP_LOG"

: >"$OP_LOG"
if OP_FAIL=1 "$script" >/dev/null 2>&1; then
  printf 'FAIL: preflight passed without 1Password vault access\n' >&2
  exit 1
fi

mv "$tmp/bin/op" "$tmp/bin/op.disabled"
if "$script" >/dev/null 2>&1; then
  printf 'FAIL: preflight passed without the 1Password CLI\n' >&2
  exit 1
fi

printf 'PASS: 1Password preflight requires CLI and vault access\n'
