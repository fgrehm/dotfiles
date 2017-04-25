# set -x
source ~/.bash/aliases
source ~/.bash/colors
source ~/.bash/completions
source ~/.bash/exports
source ~/.bash/prompt

# Get Ctrl-s vim shortcut to work on terminal
stty stop ''

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export GOPATH="$HOME/gocode"
export PATH="$PATH:/usr/local/opt/go/libexec/bin"
export PATH="$PATH:$GOPATH/bin"

[ -n "$DESK_ENV" ] && source "$DESK_ENV" || true
