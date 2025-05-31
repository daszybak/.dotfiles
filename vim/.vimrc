" Basic settings
set nocompatible            " Don't be Vi
set backspace=indent,eol,start " Make backspace work normally
set number                  " Show line numbers
set ruler                   " Show cursor position
set showcmd                 " Show typed commands
set mouse=a                 " Enable mouse support
set visualbell              " Avoid beeping

" Indentation and tabs
set expandtab               " Use spaces instead of tabs
set shiftwidth=4            " Indent size
set tabstop=4               " Tab display width
set smartindent             " Auto-indent new lines
set autoindent              " Copy indent from previous line

" Searching
set ignorecase              " Ignore case in search...
set smartcase               " ...unless uppercase used
set incsearch               " Show match while typing
set hlsearch                " Highlight matches

" Clipboard (only works if Vim is compiled with +clipboard)
if has("clipboard")
  set clipboard=unnamedplus
endif

" File handling
set nobackup
set nowritebackup
set noswapfile
set undofile
set undodir=~/.vim/undo

" Syntax highlighting
syntax on
set t_Co=256                " Support 256 colors
colorscheme default         " Use built-in colorscheme

" Disable compatibility mode in tiny Vim too
if exists('+compatible')
  set nocompatible
endif

