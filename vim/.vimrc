""" External prorams to install
" 1. exuberant ctags
" 2. ack
" 3. ripgrep
""" Plugins
call plug#begin()
" TODO Only use ctlp for windows
" File searching
if has('unix')
  Plug 'mileszs/ack.vim'
  " TODO make sure this path exists,
  " use Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } otherwise
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
else
  Plug 'ctrlpvim/ctrlp.vim'
endif
if has('nvim')
  Plug 'roxma/nvim-completion-manager'
endif
" Movement
Plug 'Lokaltog/vim-easymotion'
Plug 'ervandew/supertab'
" Code feedback
Plug 'davidhalter/jedi-vim'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'majutsushi/tagbar'
Plug 'vim-python/python-syntax'
" Utilities
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-sensible' " Super common settings
Plug 'tpope/vim-sleuth'  " Indentation settings
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" Visuals
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'dracula/vim'
Plug 'joshdick/onedark.vim'
call plug#end()

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags

if has('unix')
  """ fzf.vim
  let g:fzf_command_prefix = 'Fzf'
  let g:fzf_tags_command = 'ctags -R'
  noremap <Leader>t :FzfTags<CR>
  noremap <Leader>r :FzfBTags<CR>
  noremap <Leader>l :FzfFiles<CR>
  noremap <c-l> :FzfFiles<CR>
else
  """ ctrp.vim
   let g:ctrlp_map = '<c-l>'
   let g:ctrlp_cmd = 'CtrlP'
   let g:ctrlp_working_path_mode = 'ra'
   let g:ctrlp_root_markers = ['.ctrlp']
endif

""" ack.vim
nnoremap <Leader>f :Ack!<Space>
if executable('rg')
  let grepprg = 'rg --vimgrep'
  let g:ackprg = 'rg --vimgrep'
endif


" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

""" ale
let g:airline#extensions#ale#enabled = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

""" vim-startify
let g:startify_session_persistence = 1

"""tagbar
nmap <F8> :TagbarToggle<CR>
nmap <F3> :NERDTreeToggle<CR>

""" vim-airline
let g:airline_powerline_fonts = 1
set laststatus=2

""" Custom shortcuts
imap jj <Esc>
" Trim trailing whitespace from file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

""" General Settings
set undofile
if has('nvim')
  set termguicolors
  set backupdir=~/nvimtmp
  set directory=~/nvimtmp
  set undodir=~/.nvimundo
else
  set backupdir=~/vimtmp
  set directory=~/vimtmp
  set undodir=~/.vimundo
endif
set clipboard=unnamedplus
if has("vms")
  set nobackup " do not keep a backup file, use versions instead
else
  set backup " keep a backup file
endif
set history=1000 " keep 50 lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching
set cursorline
set relativenumber
set number
set nowrap
set hlsearch

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  let g:python_highlight_space_errors=0
  let python_highlight_all=1
  syntax on
  set background=dark
  if !has('nvim')
    set t_Co=256
    let g:onedark_termcolors=256
    let g:gruvbox_contrast_dark='hard'
    colorscheme dracula
    set guioptions-=m  "menu bar
    set guioptions-=T  "toolbar
    set guioptions-=r  "scrollbar
    set guioptions-=R  "scrollbar when in vsplit
    set guioptions-=e  "GUI tabs
    " set guifont=Inconsolata\ for\ Powerline\ 14
    " set guifont=Source\ Code\ Pro\ Semibold\ 14
    set guifont=Hack\ 14
  else
    colorscheme onedark
  endif
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!
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
  set autoindent " always set autoindenting on
endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
      \ | wincmd p | diffthis
endif

" Changing cursor based on mode
if has("autocmd")
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
