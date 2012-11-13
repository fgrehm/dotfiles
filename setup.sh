#!/usr/bin/env bash

symlinks=( bash gemrc rdebugrc irbrc )

echo "Creating symlinks..."
for link in ${symlinks[@]}; do
  target="`pwd`/${link}"
  link_name="${HOME}/.${link}"
  if ! [[ -L $link_name ]]; then
    echo "  LINK - ${link_name}"
    ln -s $target $link_name
  else
    echo "  SKIP - ${link_name}"
  fi
done

if ! $(grep -q "source `pwd`/bashrc" $HOME/.bashrc); then
  echo "Adding source to bashrc"
  echo "source `pwd`/bashrc" >> $HOME/.bashrc
else
  echo "Skipping source for bashrc"
fi

if ! [ -e $HOME/.bash_profile ]; then
  touch $HOME/.bash_profile
fi
if ! $(grep -q "source `pwd`/bash_profile" $HOME/.bash_profile); then
  echo "Adding source to bash_profile"
  echo "source `pwd`/bash_profile" >> $HOME/.bash_profile
else
  echo "Skipping source for bash_profile"
fi

if ! [ -e $HOME/.tmux.conf ]; then
  touch $HOME/.tmux.conf
fi
if ! $(grep -q "source-file `pwd`/tmux.conf" $HOME/.tmux.conf); then
  echo "Adding source-file to tmux.conf"
  echo "source-file `pwd`/tmux.conf " >> $HOME/.tmux.conf
else
  echo "Skipping source for tmux.conf"
fi

if ! [[ -L $HOME/.gitconfig ]]; then
  echo "Creating .gitconfig"
  folder=$(echo `pwd` | sed -e 's/[\/&]/\\&/g')
  sed -e "s/ROOT/$folder/g" gitconfig-template > gitconfig
  ln -s `pwd`/gitconfig $HOME/.gitconfig
else
  echo "Skipping .gitconfig"
fi
