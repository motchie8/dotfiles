set nocompatible
filetype off
" directory to install plugins
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
if &runtimepath !~# '/dein.vim'
    if !isdirectory(s:dein_repo_dir)
        execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
    endif
    execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif
if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    let g:rc_dir    = expand('~/.vim/rc')
    let s:toml      = g:rc_dir . '/dein.toml'
    let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

    call dein#load_toml(s:toml,      {'lazy': 0})
    call dein#load_toml(s:lazy_toml, {'lazy': 1})

    call dein#end()
    call dein#save_state()
endif

filetype plugin indent on
syntax enable

if isdirectory(expand($PYENV_PATH))
    let g:python3_host_prog = $PYENV_PATH . '/versions/neovim3/bin/python'
    let g:python_host_prog = $PYENV_PATH . '/versions/neovim2/bin/python'
endif

if dein#check_install()
    call dein#install()
endif

" keymappings
" ESC
inoremap <C-i> <Esc>
inoremap jj <Esc>
" move cursor
inoremap <C-j>  <down>
inoremap <C-k>  <up>
inoremap <C-h>  <left>
inoremap <C-l>  <right>
noremap <S-h> ^
noremap <S-l> $
" window operations
nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sh <C-w>h
nnoremap sl <C-w>l
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sH <C-w>H
nnoremap sL <C-w>L
nnoremap sw <C-w>_<C-w>|
nnoremap sW <C-w>
" open window in vertical split for quickfix
autocmd! FileType qf nnoremap <Space>s <C-w><Enter><C-w>L

" auto completion
imap <expr><TAB>  pumvisible() ? "<C-n>" : "<TAB>"
" search and replace
nnoremap <silent> <Space>f "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
nmap <Space>r <Space>f:%s/<C-r>///g<Left><Left>
nnoremap <silent> <Esc><Esc> :<C-u>set nohlsearch!<CR>

" tab intent
set expandtab
set tabstop=4

" serach
set ignorecase
set smartcase
set hlsearch
set incsearch

" cursor
set number
set cursorline
set showmatch

" other settings
set noswapfile
set whichwrap=b,s,h,l,<,>,[,]
set backspace=indent,eol,start

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
set sh=bash

filetype plugin indent on
