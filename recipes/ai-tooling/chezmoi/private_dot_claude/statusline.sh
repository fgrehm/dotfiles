#!/usr/bin/env bash
# Claude Code status line

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

# Current directory short name
dir=$(basename "$cwd")

# Git branch
branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

# Build output
parts=""

# Session name (if set via env var)
if [ -n "$CLOTILDE_SESSION_NAME" ]; then
  parts+=$(printf '\033[0;35m[%s] \033[0m' "$CLOTILDE_SESSION_NAME")
fi

# Directory
parts+=$(printf '\033[0;36m%s\033[0m' "$dir")

if [ -n "$branch" ]; then
  # Git branch
  parts+=$(printf ' \033[0;34m(\033[0;31m%s\033[0;34m)\033[0m' "$branch")

  # Dirty count
  dirty=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$dirty" -gt 0 ] 2>/dev/null; then
    parts+=$(printf ' \033[0;33m✏  %s\033[0m' "$dirty")
  fi

  # Ahead / behind
  ahead=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-list --count '@{upstream}..HEAD' 2>/dev/null)
  behind=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-list --count 'HEAD..@{upstream}' 2>/dev/null)
  if [ -n "$ahead" ] && [ "$ahead" -gt 0 ] 2>/dev/null; then
    parts+=$(printf ' \033[0;32m⬆ %s\033[0m' "$ahead")
  fi
  if [ -n "$behind" ] && [ "$behind" -gt 0 ] 2>/dev/null; then
    parts+=$(printf ' \033[0;31m⬇ %s\033[0m' "$behind")
  fi

  # Stash count
  stash=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')
  if [ "$stash" -gt 0 ] 2>/dev/null; then
    parts+=$(printf ' \033[0;33m📦 %s\033[0m' "$stash")
  fi
fi

# Session duration
if [ -n "$duration_ms" ] && [ "$duration_ms" != "0" ] 2>/dev/null; then
  duration_s=$((duration_ms / 1000))
  if [ "$duration_s" -ge 3600 ]; then
    dur_str=$(printf '%dh%dm' $((duration_s / 3600)) $(((duration_s % 3600) / 60)))
  elif [ "$duration_s" -ge 60 ]; then
    dur_str=$(printf '%dm' $((duration_s / 60)))
  else
    dur_str=$(printf '%ds' "$duration_s")
  fi
  parts+=$(printf '  \033[2m⏱ %s\033[0m' "$dur_str")
fi

# Lines added/removed
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  added=${lines_added:-0}
  removed=${lines_removed:-0}
  if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ] 2>/dev/null; then
    parts+=$(printf '  \033[0;32m+%s\033[0m\033[0;31m-%s\033[0m' "$added" "$removed")
  fi
fi

# Cost
if [ -n "$cost" ] && [ "$cost" != "0" ] 2>/dev/null; then
  cost_fmt=$(printf '%.2f' "$cost" 2>/dev/null)
  parts+=$(printf '  \033[2m$%s\033[0m' "$cost_fmt")
fi

# Model + context usage
if [ -n "$model" ]; then
  if [ -n "$used_pct" ]; then
    if [ "$used_pct" -ge 90 ] 2>/dev/null; then
      ctx_color='\033[0;31m' # red
    elif [ "$used_pct" -ge 70 ] 2>/dev/null; then
      ctx_color='\033[0;33m' # yellow
    else
      ctx_color='\033[2m' # dim
    fi
    parts+=$(printf "  \033[1;37m%s\033[0m  ${ctx_color}ctx:%d%%\033[0m" "$model" "$used_pct")
  else
    parts+=$(printf '  \033[1;37m%s\033[0m' "$model")
  fi
fi

printf '%s' "$parts"
