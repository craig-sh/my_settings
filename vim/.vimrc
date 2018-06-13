""" External prorams to install
" 1. exuberant ctags
" 2. ack
" 3. ripgrep or ag
" 4. pyls for Python help pip install --user python-language-server
"    Optionally install pip install --user pyls-mypy
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
let my_language_client_enable = 0
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/neosnippet'

  if my_language_client_enable
    Plug 'autozimu/LanguageClient-neovim', { 'do': ':UpdateRemotePlugins' }
  else
    Plug 'davidhalter/jedi-vim'
    Plug 'w0rp/ale'
    Plug 'zchee/deoplete-jedi'
  endif
else
  Plug 'w0rp/ale'
  Plug 'davidhalter/jedi-vim'
  Plug 'ervandew/supertab'
endif
" Movement
Plug 'Lokaltog/vim-easymotion'
" Code feedback
Plug 'tpope/vim-fugitive'
Plug 'majutsushi/tagbar'
Plug 'vim-python/python-syntax'
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'Shougo/echodoc.vim'

" Utilities
Plug 'mhinz/vim-startify'
Plug 'tpope/vim-sensible' " Super common settings
Plug 'tpope/vim-sleuth'  " Indentation settings
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'AndrewRadev/splitjoin.vim'
" Visuals
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'joshdick/onedark.vim'
call plug#end()

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags,htmlcov

if has('unix')
  """ fzf.vim
  let g:fzf_command_prefix = 'Fzf'
  let g:fzf_tags_command = 'ctags -R'
  noremap <Leader>t :FzfTags<CR>
  noremap <Leader>m :FzfBTags<CR>
  noremap <Leader>b :FzfBuffers<CR>
  noremap <Leader>l :FzfFiles<CR>
  noremap <c-l> :FzfFiles<CR>

  " Mapping selecting mappings
  nmap <leader><leader><tab> <plug>(fzf-maps-n)
  xmap <leader><leader><tab> <plug>(fzf-maps-x)
  omap <leader><leader><tab> <plug>(fzf-maps-o)

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
elseif executable('ag')
  let grepprg = 'ag --vimgrep'
  let g:ackprg = 'ag --vimgrep'
endif

if has('nvim')
  " Use deoplete.
  let g:deoplete#enable_at_startup = 1
  " Auto - Close deoplete preview window
  autocmd CompleteDone * silent! pclose!
  " deoplete tab-complete
  inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
  " disables all runtime snippets
  let g:neosnippet#disable_runtime_snippets = {
  \   '_' : 1,
  \ }
  " Snippet Settings
  let g:neosnippet#snippets_directory = '~/my_settings/vim-snips/'
  " Plugin key-mappings.
  " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)

  " SuperTab like snippets behavior.
  " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
  "imap <expr><TAB>
  " \ pumvisible() ? "\<C-n>" :
  " \ neosnippet#expandable_or_jumpable() ?
  " \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
  \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
" Required for operations modifying multiple buffers like rename.
  if my_language_client_enable
    let g:LanguageClient_serverCommands = {
        \ 'python': ['pyls']
        \ }

    " Automatically start language servers.
    let g:LanguageClient_autoStart = 1

    nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
    nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> <Leader>d :call LanguageClient_textDocument_definition()<CR>
    nnoremap <silent> <Leader>r :call LanguageClient_textDocument_rename()<CR>
    nnoremap <silent> <Leader>n :call LanguageClient_textDocument_references()<CR>
    nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
  else
    let g:ale_linters = {
    \   'python': ['mypy', 'prospector'],
    \}
    let g:airline#extensions#ale#enabled = 1
    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    " """ Jedi
    let g:jedi#auto_vim_configuration = 0
    let g:jedi#use_tabs_not_buffers = 0  " current default is 1.
    let g:jedi#completions_enabled = 0
    let g:jedi#smart_auto_mappings = 1
    let g:jedi#popup_on_dot = 0
  endif
else
""" ale
  let g:airline#extensions#ale#enabled = 1
  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
endif

""" vim-startify
let g:startify_session_persistence = 1

"""tagbar
nmap <F8> :TagbarToggle<CR>
nmap <F3> :NERDTreeToggle<CR>

""" vim-airline
let g:airline_powerline_fonts = 1
let g:airline_theme='onedark'
set laststatus=2

""" echodoc
set noshowmode
let g:echodoc_enable_at_startup = 1

""" Custom shortcuts
imap jj <Esc>
" Trim :railing whitespace from file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>

" Auto-insert closing chars
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>
inoremap ' ''<Left>
inoremap " ""<Left>

""" General Settings
set list
set undofile
let g:onedark_terminal_italics=1
if has('nvim')
  set termguicolors
  set backupdir=~/nvimtmp//
  set directory=~/nvimtmp//
  set undodir=~/.nvimundo
else
  set backupdir=~/vimtmp//
  set directory=~/vimtmp//
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
set hidden " Switch buffers without saving

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  let g:python_highlight_space_errors=1
  let python_highlight_all=1
  let g:python_slow_sync=0
  syntax on
  set background=dark
  if !has('nvim')
    set t_Co=256
    let g:onedark_termcolors=256
    let g:gruvbox_contrast_dark='hard'
    "colorscheme dracula
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
if !has("nvim") && has("autocmd")
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" relative path (src/foo.txt)
nnoremap <leader>cf :let @+=expand("%")<CR>
" Work Settings
noremap <Leader><Leader>f :FzfAg
" qlog of current file
noremap <Leader><Leader>l :! bzr qlog % &<CR>
" qlog of all files
noremap <Leader><Leader>ql :! bzr qlog &<CR>
" qdiff of current file
noremap <Leader><Leader>d :! bzr qdiff % &<CR>
" qblame of current file
noremap <Leader><Leader>qb :! bzr qblame % -L <C-r>=line('.')<CR> &<CR>
" qdiff of all files
noremap <Leader><Leader>fd :! bzr qdiff &<CR>
" make python tags
noremap <Leader><Leader>mt :! ctags -R --languages=python<CR>
" insert the current datetime
imap <Leader><Leader>dt <C-R>=strftime('%Y%m%d')<CR>

let g:ackprg = 'ag --vimgrep -p=/home/craig/.agignore'
let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_enter = 0
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

