#!/usr/bin/env bash

symlinks=( bash gemrc rdebugrc rvmrc )

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

target="`pwd`/devstep.yml"
link_name="${HOME}/devstep.yml"
if ! [[ -L $link_name ]]; then
  echo "  LINK - ${link_name}"
  ln -s $target $link_name
else
  echo "  SKIP - ${link_name}"
fi

target="`pwd`/Vagrantfile"
link_name="${HOME}/.vagrant.d/Vagrantfile"
if ! [[ -L $link_name ]]; then
  mkdir -p $HOME/.vagrant.d
  echo "  LINK - ${link_name}"
  ln -s $target $link_name
else
  echo "  SKIP - ${link_name}"
fi


if ! $(grep -q "source `pwd`/bashrc" $HOME/.bashrc); then
  echo "Adding source to bashrc"
  echo "source `pwd`/bashrc" >> $HOME/.bashrc
else
  echo "Skipping source for bashrc"
fi

if ! [ -d $HOME/bin ]; then
  echo "Creating \`${HOME}/bin\` directory"
  mkdir -p $HOME/bin
else
  echo "Skipping \`${HOME}/bin\` creation"
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



#libnss
#devstep + plugins
#easy-lb
#docker images
#zeal
