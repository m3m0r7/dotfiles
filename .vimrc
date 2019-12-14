set number
set title

syntax on
set ignorecase
set smartcase

set expandtab
set tabstop=4
set shiftwidth=4

set ruler
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
set backupdir=~/.vimbackup
set hlsearch
set list
set showmatch



map <C-n> :NERDTreeToggle<CR>
"autocmd vimenter * NERDTree

call plug#begin('~/.vim/plugged')
    Plug 'tomasr/molokai'
    Plug 'tomtom/tcomment_vim'
    Plug 'nathanaelkane/vim-indent-guides'
    Plug 'vim-scripts/AnsiEsc.vim'
    Plug 'bronson/vim-trailing-whitespace'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'sheerun/vim-polyglot'
call plug#end()

let g:indent_guides_enable_on_vim_startup = 1
let g:airline_theme = 'wombat'
set laststatus=2
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#wordcount#enabled = 1
let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'y', 'z']]
let g:airline_section_c = '%t'
let g:airline_section_x = '%{&filetype}'
let g:airline_section_z = '%3l:%2v %{airline#extensions#ale#get_warning()} %{airline#extensions#ale#get_error()}'
let g:airline#extensions#ale#error_symbol = ' '
let g:airline#extensions#ale#warning_symbol = ' '
let g:airline#extensions#default#section_truncate_width = {}
let g:airline#extensions#whitespace#enabled = 1

colorscheme molokai
