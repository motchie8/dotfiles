" setup dein.vim
if &compatible
  set nocompatible
endif
filetype off
" directory to install plugins
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if !isdirectory(s:dein_repo_dir)
  execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
endif
execute 'set runtimepath+=' . s:dein_repo_dir

if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)
    call dein#add(s:dein_repo_dir) 
    let g:rc_dir    = expand('~/.vim/rc')
    let s:toml      = g:rc_dir . '/dein.toml'
    let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif
if dein#check_install()
    call dein#install()
endif
filetype plugin indent on
syntax enable

let s:pyenv_root = expand('~/.pyenv')
" python path
if isdirectory(s:pyenv_root)
    let g:python3_host_prog = s:pyenv_root . '/versions/neovim3/bin/python'
    let g:python_host_prog = s:pyenv_root . '/versions/neovim2/bin/python'
endif

set hidden

" keymappings
inoremap jj <ESC>
nnoremap ; :

" move cursor
inoremap <C-j>  <down>
inoremap <C-k>  <up>
inoremap <C-h>  <left>
inoremap <C-l>  <right>
noremap <S-h> ^
noremap <S-l> $
" move cursor
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sh <C-w>h
nnoremap sl <C-w>l
" move window
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sH <C-w>H
nnoremap sL <C-w>L
nnoremap sw <C-w>_<C-w>|
nnoremap sW <C-w>
" buffer operations
nnoremap <silent> <Space>bp :bprevious<CR>
nnoremap <silent> <Space>bn :bnext<CR>
nnoremap <silent> <Space>bb :b#<CR>
nnoremap <silent> <Space>bd :bdelete<CR>

" open window in vertical split for quickfix
autocmd! FileType qf nnoremap <Space>s <C-w><Enter><C-w>L

" search and replace
nnoremap <silent> <Space>f "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
nmap <Space>r <Space>f:%s/<C-r>///g<Left><Left>
nnoremap <silent> <Esc><Esc> :<C-u>set nohlsearch!<CR>

" tab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

" serach
set ignorecase
set smartcase
set hlsearch
set incsearch

" cursor
set number
set cursorline
" set cursorcolumn
set showmatch
set ruler

" file
set noswapfile
set autoread
set nobackup
set nowritebackup

" line
set whichwrap=b,s,h,l,<,>,[,]

" scroll
set scrolloff=12
set sidescrolloff=16
set sidescroll=1

" blank
set backspace=indent,eol,start
set list

" sourd
set visualbell t_vb=
set noerrorbells 

" other settings
set cmdheight=2
set laststatus=2

" clipboard
set clipboard+=unnamedplus

" autocomplete
inoremap { {}<Left>
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap ( ()<ESC>i
inoremap (<Enter> ()<Left><CR><ESC><S-o>
inoremap [ []<ESC>i
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

" color schema
syntax on
set t_Co=256
colorscheme iceberg

" shell
set sh=zsh

filetype plugin indent on
