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

if has('clipboard') && (!empty($DISPLAY) || has('mac') || has('gui_running'))
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

" Detect Makefiles and force tabs
autocmd FileType make set noexpandtab tabstop=8 shiftwidth=8 softtabstop=0

let mapleader = " "

xnoremap y "+y
nnoremap y "+y
nnoremap y "+y
vnoremap y "+y
nnoremap d "+d
vnoremap d "+d
nnoremap p "+p
vnoremap p "+p

call plug#begin('~/.vim/plugged')

" Fuzzy finder
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" File explorer
Plug 'preservim/nerdtree'

" Optional: Icons (if your terminal supports them)
Plug 'ryanoasis/vim-devicons'

" Optional: Statusline
Plug 'vim-airline/vim-airline'

call plug#end()

" NERDTree toggle
nnoremap <Leader>n :NERDTreeToggle<CR>

" Fuzzy file finder
nnoremap <C-p> :Files<CR>

" Fuzzy grep
nnoremap <Leader>g :Rg<CR>

" Change directory to project root (git root)
autocmd BufEnter * silent! lcd `git rev-parse --show-toplevel 2>/dev/null`


