#!/usr/bin/env bash
source "$CHEZMOI_SOURCE_DIR/scripts/ui.bash"
set -eo pipefail

SSH_URL="git@github.com:fgrehm/dotagents.git"
HTTPS_URL="https://github.com/fgrehm/dotagents.git"

if [ -d /data/projects ]; then
  PARENT="/data/projects/oss"
elif [ -d "$HOME/Projects" ]; then
  PARENT="$HOME/Projects/oss"
else
  PARENT="$HOME/.local/share"
fi
TARGET="$PARENT/dotagents"

mkdir -p "$PARENT"

is_dotagents_checkout() {
  local origin
  git -C "$TARGET" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1
  origin="$(git -C "$TARGET" remote get-url origin 2>/dev/null || true)"
  case "$origin" in
  "$SSH_URL" | "$HTTPS_URL" | "ssh://git@github.com/fgrehm/dotagents.git") return 0 ;;
  *) return 1 ;;
  esac
}

if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  if ! is_dotagents_checkout; then
    log_error "$TARGET exists but is not a dotagents checkout; leaving it untouched"
    exit 1
  fi
  log_info "Reusing existing dotagents checkout at $TARGET (not pulling)"
else
  tmpdir="$(mktemp -d "$PARENT/.dotagents-clone.XXXXXX")"
  trap 'rm -rf -- "$tmpdir"' EXIT
  clone_dir=""

  log_info "Cloning dotagents over SSH"
  if GIT_SSH_COMMAND="ssh -o BatchMode=yes" git clone --quiet "$SSH_URL" "$tmpdir/ssh-checkout"; then
    clone_dir="$tmpdir/ssh-checkout"
  else
    log_skip "SSH clone failed; retrying dotagents clone over HTTPS"
    git clone --quiet "$HTTPS_URL" "$tmpdir/https-checkout" || {
      log_error "Could not clone dotagents over SSH or HTTPS"
      exit 1
    }
    clone_dir="$tmpdir/https-checkout"
  fi

  if [ ! -x "$clone_dir/install.sh" ]; then
    log_error "Cloned dotagents repo has no executable install.sh"
    exit 1
  fi
  if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
    log_error "$TARGET appeared during clone; refusing to overwrite it"
    exit 1
  fi
  mv -- "$clone_dir" "$TARGET"
  log_info "Cloned dotagents to $TARGET"
fi

if [ ! -x "$TARGET/install.sh" ]; then
  log_error "$TARGET/install.sh is missing or not executable"
  exit 1
fi

"$TARGET/install.sh"
log_info "dotagents installation completed"
