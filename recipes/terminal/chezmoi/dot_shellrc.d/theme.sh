# shellcheck shell=sh
# Apply the effective base16 theme to the current shell session.
# Resolution order: per-window > global > default.
_theme_init() {
  _ti_shell="$HOME/.local/share/tinted-theming/tinty/repos/tinted-shell/scripts"
  _ti_fzf="$HOME/.local/share/tinted-theming/tinty/repos/tinted-fzf/sh"
  _ti_scheme=""

  if [ -n "${ALACRITTY_WINDOW_ID:-}" ]; then
    _ti_wf="${XDG_RUNTIME_DIR:-/tmp}/theme/window-$ALACRITTY_WINDOW_ID"
    [ -f "$_ti_wf" ] && _ti_scheme=$(cat "$_ti_wf")
  fi

  if [ -z "$_ti_scheme" ]; then
    _ti_scheme=$(cat "$HOME/.local/share/theme/current" 2>/dev/null) || true
  fi

  [ -z "$_ti_scheme" ] && _ti_scheme="base16-gruvbox-dark-hard"

  # shellcheck disable=SC1090
  [ -f "$_ti_shell/$_ti_scheme.sh" ] && . "$_ti_shell/$_ti_scheme.sh"
  # shellcheck disable=SC1090
  [ -f "$_ti_fzf/$_ti_scheme.sh" ] && . "$_ti_fzf/$_ti_scheme.sh"

  export BAT_THEME="base16"

  unset _ti_shell _ti_fzf _ti_scheme _ti_wf
}

_theme_init
unset -f _theme_init
