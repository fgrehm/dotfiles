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

if ! [[ -L $HOME/.gitconfig ]]; then
  echo "Creating .gitconfig"
  folder=$(echo `pwd` | sed -e 's/[\/&]/\\&/g')
  sed -e "s/ROOT/$folder/g" gitconfig-template > gitconfig
  ln -s `pwd`/gitconfig $HOME/.gitconfig
else
  echo "Skipping .gitconfig"
fi
