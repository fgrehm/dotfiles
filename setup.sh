#!/usr/bin/env bash

if ! [[ -L $HOME/.vimrc ]]; then
  ln -s `pwd`/.vimrc $HOME/.vimrc
fi


if ! [[ -L $HOME/.vim ]]; then
  ln -s `pwd`/vim $HOME/.vim
fi

if ! [[ -d `pwd`/vim/bundle/vundle/.git  ]]; then
  git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
fi

echo "Open up vim and run :BundleInstall"
echo "After that, run \"(cd ~/.vim/bundle/Command-T/ruby/command-t/ && ruby extconf.rb && make)\""
