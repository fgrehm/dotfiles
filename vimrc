set nocompatible               " be iMproved
filetype off                   " required!
let mapleader = ","

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required!
Bundle 'gmarik/vundle'

Bundle 'altercation/vim-colors-solarized'

Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-rails'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-repeat'
Bundle 'rstacruz/sparkup'
Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
Bundle 'L9'
Bundle 'ervandew/supertab'

Bundle 'tsaleh/vim-align'
Bundle 'briandoll/change-inside-surroundings.vim'
Bundle 'scrooloose/nerdcommenter'

Bundle 'scrooloose/nerdtree'
Bundle 'bufexplorer.zip'

Bundle 'Command-T'
Bundle 'jeetsukumaran/vim-filesearch'
Bundle 'SearchComplete'

Bundle 'matchit.zip'
Bundle 'ruby-matchit'

Bundle 'tpope/vim-cucumber'
Bundle 'tpope/vim-haml'
Bundle 'tpope/vim-markdown'
Bundle 'bbommarito/vim-slim'
Bundle 'rodjek/vim-puppet'
Bundle 'kchmck/vim-coffee-script'
Bundle 'VimClojure'
Bundle 'lunaru/vim-less'
Bundle 'pangloss/vim-javascript'
Bundle 'briancollins/vim-jst'

filetype plugin indent on

syntax on

set bg=dark
colorscheme desert

set hidden
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smarttab
set ruler
set number
set nowrap
set encoding=utf8
set fileencoding=utf8
set smartcase
set hlsearch
set cursorline
set laststatus=2
set showcmd
set showmode
set noerrorbells
set novisualbell
set backspace=indent,eol,start
set completeopt=menu,preview
set autoread
set autowrite
set showfulltag
set shiftround
set guioptions-=T
set gdefault
set incsearch
set showmatch
set wildignore+=*.o,*.obj,.git,tmp/**,build/**,coverage/**

set tags+=gems.tags

set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%04l,%04v]\ [LEN=%L]

" enable per-directory .vimrc files
set exrc
" disable unsafe commands in local .vimrc files
set secure

map <C-t> <Esc>:CommandT<CR>
map <C-s> <Esc>:w<CR>
map <C-S> <Esc>:w<CR>

map! <C-s> <Esc>:w<CR>a
map! <C-S> <Esc>:w<CR>a

" set mapping expand the window
noremap <expr> <silent> <Space><Space> ":vertical res<CR>:res<CR>"
noremap <Space>= <C-w>=
noremap <Space>_ <C-w>_
noremap <Space><Bar> <C-w><Bar>
noremap <Space>o <C-w>o

let g:NERDCreateDefaultMappings = 0
map <leader>C <plug>NERDCommenterComment

if has("gui_macvim")
  set guifont=Menlo:h14
else
  set guifont=Monospace\ 11.5
endif

" Delete trailing white space when saving
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

au BufRead,BufNew *.coffee set ft=coffee
au BufRead,BufNew *.html.erb set ft=eruby.html
au BufRead,BufNew Gemfile set ft=ruby
au BufRead,BufNew Guardfile set ft=ruby
au BufRead,BufNew Procfile set ft=ruby
au BufRead,BufNew *.ru set ft=ruby

au FocusLost * :CommandTFlush
au BufWrite * :call DeleteTrailingWS()
