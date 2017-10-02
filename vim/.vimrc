" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2011 Apr 15
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

""""""""""""""""""""""""""""" vim-plug
call plug#begin()
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Lokaltog/vim-easymotion'
" Plug 'Lokaltog/vim-powerline'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'python-mode/python-mode'
Plug 'davidhalter/jedi-vim'
Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'
Plug 'ervandew/supertab'
" Plug 'scrooloose/syntastic'
" Plug 'tpope/vim-fugitive'
" Plug 'airblade/vim-gitgutter'
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'xolox/vim-misc'
Plug 'majutsushi/tagbar'
" Plug 'xolox/vim-session'
Plug 'mhinz/vim-startify'
Plug 'mileszs/ack.vim'
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }
" On-demand loading
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
call plug#end()

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags

""" Searching
let g:ackprg = 'ag --vimgrep -p=/home/craig/.agignore'
" let g:ackpreview = 0

"""""" Python mode settings 
" let g:pymode = 0
let g:pymode_options = 0
let g:pymode_indent = 1
let g:pymode_folding = 0
let g:pymode_motion = 1
let g:pymode_doc = 0
let g:pymode_lint = 0
let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_trim_whitespaces = 0

""""""""""""""""""JEDI""""""""""""""""""
let g:jedi#use_tabs_not_buffers = 0
" let g:jedi#goto_definitions_command = "<leader>R"
" let g:pymode_rope_goto_definition_bind = "<C-]>"


"""Saving sessions"""
let g:startify_session_persistence = 1
" let g:session_autosave = 'yes'
" let g:session_autosave_periodic = 1
" let g:session_autoload = 'no'

""""""""""Mappings""""""""
let g:ctrlp_map = '<c-l>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'ra'
nnoremap <leader>jd :YcmCompleter GoTo<CR>
noremap <Leader>f :Ack! 
noremap <Leader>t :CtrlPTag<CR>
nmap <F8> :TagbarToggle<CR>
imap jj <Esc>
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>
" Don't use Ex mode, use Q for formatting
map Q gq
"""""""""""""""""""""""""""""""""""""
" allow backspacing over everything in insert mode
set backspace=indent,eol,start
set backupdir=~/vimtmp
set directory=~/vimtmp
set undofile
set undodir=~/.vimundo
if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=500		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

set relativenumber
set number
set cursorline

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  "set t_Co=256 " Explicitly tell Vim that the terminal supports 256 colors
  "let g:solarized_termcolors=16
  let python_highlight_all=1
  syntax on
  set background=dark
  "colorscheme solarized
  let g:gruvbox_contrast_dark = 'hard'
  colorscheme gruvbox
  "colorscheme onedark
  "color dracula
  "colorscheme default
  set hlsearch
  " set guifont=Inconsolata\ for\ Powerline\ 14
  " set guifont=Inconsolata\ Bold\ 14
  " set guifont=Source\ Code\ Pro\ 12
  "set guifont=Source\ Code\ Pro\ Medium\ 12
  " set guifont=Hack\ Bold\ 11
  set guifont=Hack\ 11
  "set guifont=Fira\ Code\ Medium\ 12
  "set guifont=Ubuntu\ Mono\ Bold\ 13
  set guioptions-=m  "menu bar
  set guioptions-=T  "toolbar
  set guioptions-=r  "scrollbar
  set guioptions-=R  "scrollbar when in vsplit
  set guioptions-=e  "GUI tabs
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Commented line under current one because of pathogen
  " filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  " autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

set rtp+=$HOME/.local/lib/python3.5/site-packages/powerline/bindings/vim/
"let g:Powerline_symbols = 'fancy'
let g:airline_powerline_fonts = 1
set laststatus=2
"set statusline +=%3*%y%*                "file type
"set statusline +=%4*\ %<%F%*            "full path
"set statusline +=%2*%m%*                "modified flag
"set statusline +=%1*%=%5l%*             "current line
"set statusline +=%2*/%L%*               "total lines
"set statusline +=%1*%4v\ %*             "virtual column number
"set statusline +=%2*0x%04B\ %*          "character under curso

"hi User1 guifg=#eea040 guibg=#222222
"hi User2 guifg=#dd3333 guibg=#222222
"hi User3 guifg=#ff66ff guibg=#222222
"hi User4 guifg=#a0ee40 guibg=#222222
"hi User5 guifg=#eeee40 guibg=#222222
"hi Normal  ctermbg=none
"""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""Access System Clipboard"""""""""
set clipboard=unnamedplus
"""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""Changing cursor based on mode""""""""""""""""""
if has("autocmd")
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4       " The width of a TAB is set to 4.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 4.

set shiftwidth=4    " Indents will have a width of 4

set softtabstop=4   " Sets the number of columns for a TAB

set expandtab       " always uses spaces instead of tab characters

set nowrap
