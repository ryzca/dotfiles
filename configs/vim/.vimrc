set encoding=utf-8
scriptencoding utf-8

set fileencoding=utf-8
set fileencodings=ucs-boms,utf-8,euc-jp,cp932
set fileformats=unix,dos,mac
set ambiwidth=double

"  for XDB Base Directory
if empty($MYVIMRC) | let $MYVIMRC = expand('<sfile>:p') | endif
if empty($XDG_CACHE_HOME)  | let $XDG_CACHE_HOME  = $HOME."/.cache"       | endif
if empty($XDG_CONFIG_HOME) | let $XDG_CONFIG_HOME = $HOME."/.config"      | endif
if empty($XDG_DATA_HOME)   | let $XDG_DATA_HOME   = $HOME."/.local/share" | endif
if empty($XDG_STATE_HOME)  | let $XDG_STATE_HOME  = $HOME."/.local/state" | endif

set runtimepath^=$XDG_CONFIG_HOME/vim
set runtimepath+=$XDG_DATA_HOME/vim
set runtimepath+=$XDG_CONFIG_HOME/vim/after
set packpath^=$XDG_DATA_HOME/vim,$XDG_CONFIG_HOME/vim
set packpath+=$XDG_CONFIG_HOME/vim/after,$XDG_DATA_HOME/vim/after

let g:netrw_home = $XDG_DATA_HOME."/vim"
call mkdir($XDG_DATA_HOME."/vim/spell", "p", 0700)
set backupdir=$XDG_STATE_HOME/vim/backup | call mkdir(&backupdir, "p", 0700)
set directory=$XDG_STATE_HOME/vim/swap   | call mkdir(&directory, "p", 0700)
set undodir=$XDG_STATE_HOME/vim/undo     | call mkdir(&undodir,   "p", 0700)
set viewdir=$XDG_STATE_HOME/vim/view     | call mkdir(&viewdir,   "p", 0700)
set viminfo+=n$XDG_DATA_HOME/vim/viminfo

"  view
set autoread
set title
set number
set ruler
set laststatus=2
set showcmd
set showmode
set wildmenu
set wildmode=longest:full,full
set showmatch
source $VIMRUNTIME/macros/matchit.vim
set history=10000
set background=dark

"  indent
set expandtab
set softtabstop=4
set tabstop=4
set autoindent
set smartindent
set shiftwidth=4
set smarttab
if &term =~ "xterm"
  let &t_SI .= "\e[?2004h"
  let &t_EI .= "\e[?2004l"
  let &pastetoggle = "\e[201~"

  function XTermPasteBegin(ret)
      set paste
      return a:ret
  endfunction

  inoremap <special> <expr> <Esc>[200~ XTermPasteBegin("")
endif

"  cursor
set cursorline
set cursorcolumn
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
set whichwrap=b,s,h,l,<,>,[,],~
set backspace=indent,eol,start
if has("mouse")
  set mouse=a
  if has("mouse_sgr")
      set ttymouse=sgr
  elseif v:version > 703 || v:version is 703 && has("patch632")
      set ttymouse=sgr
  else
      set ttymouse=xterm2
  endif
endif

"  search
set incsearch
set ignorecase
set smartcase
set hlsearch
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

"  plugins
if &compatible
  set nocompatible
endif
let s:dein_base = $XDG_DATA_HOME . "/vim/dein/"
let s:dein_src = s:dein_base . "repos/github.com/Shougo/dein.vim"
execute "set runtimepath+=" .. s:dein_src
call dein#begin(s:dein_base)
call dein#add(s:dein_src)

call dein#add("w0ng/vim-hybrid")
call dein#add("itchyny/lightline.vim")

call dein#end()
filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

if dein#is_available("vim-hybrid")
  let g:hybrid_use_iTerm_colors = 1
  colorscheme hybrid
  syntax on
  hi LineNr ctermfg=244 guifg=#373b41
endif

if dein#is_available("lightline.vim")
  let g:lightline = { 'colorscheme': 'one' }
endif
