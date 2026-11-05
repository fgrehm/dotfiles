#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
script="$root/recipes/omarchy/chezmoi/dot_local/bin/executable_wip-backup"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export MOCK_MOUNTPOINT="$tmp/external"
export RESTIC_LOG="$tmp/restic-args"
export PATH="$tmp/bin:$PATH"
mkdir -p "$HOME/.config/wip-backup" "$HOME/Dropbox/offline" "$HOME/Projects/project/.ssh" "$HOME/Projects/project/.bb/threads" "$HOME/.config/omarchy/screen-time" "$MOCK_MOUNTPOINT/repo" "$tmp/bin"
printf 'private key fixture\n' >"$HOME/Projects/project/.ssh/id_ed25519"
printf 'session fixture\n' >"$HOME/Projects/project/.bb/threads/session.jsonl"
printf 'test password\n' >"$HOME/.config/wip-backup/restic-password"
chmod 600 "$HOME/.config/wip-backup/restic-password"
printf '{}\n' >"$HOME/.config/omarchy/screen-time/history.json"
cat >"$HOME/.config/wip-backup/config.sh" <<'CONFIG'
BACKUP_MOUNTPOINT="$HOME/../external"
RESTIC_REPOSITORY="$HOME/../external/repo"
RESTIC_PASSWORD_FILE="$HOME/.config/wip-backup/restic-password"
DROPBOX_PATHS=("$HOME/Dropbox/offline")
PROJECT_PATHS=("$HOME/Projects")
CONFIG

cat >"$tmp/bin/mountpoint" <<'MOCK'
#!/usr/bin/env bash
[[ ${@: -1} == "$MOCK_MOUNTPOINT" ]]
MOCK
cat >"$tmp/bin/findmnt" <<'MOCK'
#!/usr/bin/env bash
printf 'rw,relatime\n'
MOCK
cat >"$tmp/bin/restic" <<'MOCK'
#!/usr/bin/env bash
if [[ $1 == cat && ${2:-} == config ]]; then
  exit 0
fi
printf '<%s>\n' "$@" >>"$RESTIC_LOG"
MOCK
chmod +x "$tmp/bin/mountpoint" "$tmp/bin/findmnt" "$tmp/bin/restic"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

: >"$RESTIC_LOG"
"$script" --dry-run || fail "dry-run backup failed"
grep -qx '<--dry-run>' "$RESTIC_LOG" || fail "dry-run flag was not passed to Restic"
grep -Fqx "<$HOME/Dropbox/offline>" "$RESTIC_LOG" || fail "Dropbox source was not passed"
grep -Fqx "<$HOME/Projects>" "$RESTIC_LOG" || fail "project source was not passed"
grep -Fqx "<$HOME/.config/omarchy/screen-time/history.json>" "$RESTIC_LOG" || fail "Screen Time history was not passed"
for pattern in '**/.ssh' '**/.bb' "$HOME/.ssh" "$HOME/.bb" "$HOME/.config/bb"; do
  awk -v expected="<$pattern>" 'previous == "<--exclude>" && $0 == expected { found = 1 } { previous = $0 } END { exit !found }' "$RESTIC_LOG" || fail "Restic did not receive exclude pattern $pattern"
done

: >"$RESTIC_LOG"
"$script" || fail "normal backup failed"
if grep -qx '<--dry-run>' "$RESTIC_LOG"; then
  fail "normal backup unexpectedly used dry-run"
fi

: >"$RESTIC_LOG"
if MOCK_MOUNTPOINT="$tmp/not-mounted" "$script" >/dev/null 2>&1; then
  fail "backup succeeded without the external drive mounted"
fi
if [[ -s $RESTIC_LOG ]]; then
  fail "Restic ran despite the missing external drive"
fi

cp "$HOME/.config/wip-backup/config.sh" "$tmp/config.sh"
sed -i "s#PROJECT_PATHS=.*#PROJECT_PATHS=(\"$HOME/.ssh\")#" "$HOME/.config/wip-backup/config.sh"
: >"$RESTIC_LOG"
if "$script" >/dev/null 2>&1; then
  fail "backup succeeded when a sensitive SSH directory was selected directly"
fi
if [[ -s $RESTIC_LOG ]]; then
  fail "Restic ran despite a sensitive SSH source"
fi
cp "$tmp/config.sh" "$HOME/.config/wip-backup/config.sh"

sed -i "s#RESTIC_REPOSITORY=.*#RESTIC_REPOSITORY=\"$HOME/outside\"#" "$HOME/.config/wip-backup/config.sh"
if "$script" >/dev/null 2>&1; then
  fail "backup succeeded with a repository outside the external drive"
fi
cp "$tmp/config.sh" "$HOME/.config/wip-backup/config.sh"

chmod 644 "$HOME/.config/wip-backup/restic-password"
if "$script" >/dev/null 2>&1; then
  fail "backup succeeded with an insecurely-permissioned password file"
fi
chmod 600 "$HOME/.config/wip-backup/restic-password"

printf 'PASS: WIP backup validates sources, mount, repository, password, and dry-run behavior\n'
