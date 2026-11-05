#!/usr/bin/env bash
# shellcheck disable=SC2034
# WIP backup configuration, seeded once so chezmoi preserves later edits.
# Set the mount and repository to paths on the external drive.
BACKUP_MOUNTPOINT=""
RESTIC_REPOSITORY=""
RESTIC_PASSWORD_FILE="$HOME/.config/wip-backup/restic-password"

# Add only Dropbox files/folders that have been made available offline.
DROPBOX_PATHS=()

# Remove or add project roots to match this machine. Missing entries cause the
# backup to stop rather than silently skip a place where WIP may live.
PROJECT_PATHS=("$HOME/Projects" "/data/projects")
