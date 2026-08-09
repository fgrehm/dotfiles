# shellcheck shell=bash
# Git aliases and shell completions.

if ! command -v git &>/dev/null; then
  return 0
fi

# --- Aliases ---
alias ga='git add'
alias gap='git add -p'
alias gc='git commit -m'
alias gcA='git commit --amend -m'
alias gca='git commit --amend -C HEAD'
alias gci='git commit -v'
alias gco='git checkout'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdn='git --no-pager diff'
alias gdnc='git --no-pager diff --cached'
alias gdm='git diff main...'
alias gsh='git show'
alias gp='git push'
alias gplr='git pull --rebase'
alias gpl='git pull'
alias gr='git reset'
alias gs='git status'
alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)%Creset' --abbrev-commit"

# --- Zsh completions for git aliases ---
if [ -n "$ZSH_VERSION" ]; then
  compdef _git ga=git-add
  compdef _git gap=git-add
  compdef _git gc=git-commit
  compdef _git gcA=git-commit
  compdef _git gca=git-commit
  compdef _git gci=git-commit
  compdef _git gco=git-checkout
  compdef _git gd=git-diff
  compdef _git gdc=git-diff
  compdef _git gdn=git-diff
  compdef _git gdnc=git-diff
  compdef _git gdm=git-diff
  compdef _git gsh=git-show
  compdef _git gp=git-push
  compdef _git gplr=git-pull
  compdef _git gpl=git-pull
  compdef _git gr=git-reset
  compdef _git gs=git-status
fi

# --- Bash completions for git aliases ---
# git's __git_complete wires an alias to a subcommand completion function.
# The git completion is lazy-loaded by bash-completion, so source it here to
# make __git_complete available.
if [ -n "$BASH_VERSION" ]; then
  # git completion is lazy-loaded by bash-completion; only source it if
  # __git_complete isn't already available.
  if ! declare -F __git_complete >/dev/null 2>&1; then
    if [ -f /usr/share/bash-completion/completions/git ]; then
      . /usr/share/bash-completion/completions/git
    elif [ -f /etc/bash_completion.d/git ]; then
      . /etc/bash_completion.d/git
    fi
  fi
  if declare -F __git_complete >/dev/null 2>&1; then
    __git_complete ga _git_add
    __git_complete gap _git_add
    __git_complete gc _git_commit
    __git_complete gcA _git_commit
    __git_complete gca _git_commit
    __git_complete gci _git_commit
    __git_complete gco _git_checkout
    __git_complete gd _git_diff
    __git_complete gdc _git_diff
    __git_complete gdn _git_diff
    __git_complete gdnc _git_diff
    __git_complete gdm _git_diff
    __git_complete gsh _git_show
    __git_complete gp _git_push
    __git_complete gplr _git_pull
    __git_complete gpl _git_pull
    __git_complete gr _git_reset
    __git_complete gs _git_status
  fi
fi
