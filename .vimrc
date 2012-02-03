set nocompatible               " be iMproved
filetype off                   " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'
Bundle 'Command-T'

syntax on
filetype plugin indent on

map <C-t> <Esc>:CommandT<CR>
