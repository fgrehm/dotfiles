#!/usr/bin/env bash

if ! [[ -L $HOME/.vimrc ]]; then
  ln -s `pwd`/vimrc $HOME/.vimrc
fi

if ! [[ -L $HOME/.vim ]]; then
  ln -s `pwd`/vim $HOME/.vim
fi

if ! $(grep -q "source `pwd`/bashrc" $HOME/.bashrc); then
  echo "source `pwd`/bashrc" >> $HOME/.bashrc
fi

if ! [[ -L $HOME/.bash ]]; then
  ln -s `pwd`/bash $HOME/.bash
fi

if ! [[ -L $HOME/.gitconfig ]]; then
  folder=$(echo `pwd` | sed -e 's/[\/&]/\\&/g')
  sed -e "s/ROOT/$folder/g" gitconfig-template > gitconfig
  ln -s `pwd`/gitconfig $HOME/.gitconfig
fi

if ! [[ -L $HOME/.gemrc ]]; then
  ln -s `pwd`/gemrc $HOME/.gemrc
fi

if ! [[ -d `pwd`/vim/bundle/vundle/.git  ]]; then
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

echo "Open up vim and run :BundleInstall"
echo "After that, run \"(cd ~/.vim/bundle/Command-T/ruby/command-t/ && ruby extconf.rb && make)\""
