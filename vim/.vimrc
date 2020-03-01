
""" General Settings
set undofile
set clipboard=unnamedplus

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

set history=1000 " lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching
set cursorline
set relativenumber
set number
set nowrap
set hlsearch
set hidden " Switch buffers without saving

set autoindent
filetype plugin indent on


" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set background=dark
  set t_Co=256
  colorscheme slate
  set guioptions-=m  "menu bar
  set guioptions-=T  "toolbar
  set guioptions-=r  "scrollbar
  set guioptions-=R  "scrollbar when in vsplit
  set guioptions-=e  "GUI tabs
endif

set laststatus=2
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags,htmlcov

""" Custom shortcuts
imap jj <Esc>
" Trim :railing whitespace from file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
" Edit vimrc
nnoremap <Leader>ev :e $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>
nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>

" relative path (src/foo.txt)
nnoremap <Leader>cf :let @+=expand("%")<CR>
" PWD
nnoremap <Leader>pwd :! pwd<CR>

nnoremap <Leader>ss :syntax sync fromstart<CR>

" External shortcuts, start with <Leader><Leader>
" make python tags
noremap <Leader><Leader>mt :! ctags -R --languages=python<CR>
" insert the current datetime
imap <Leader><Leader>dt <C-R>=strftime('%Y%m%d')<CR>
" log of current file
noremap <Leader><Leader>l :! smerge log % &<CR>
" log of all files
noremap <Leader><Leader>gl :! smerge $(pwd) &<CR>

" diff of current file
noremap <Leader><Leader>d :! meld % &<CR>

" blame of current file
noremap <Leader><Leader>gb :! smerge blame % <C-r>=line('.')<CR> &<CR>

" qdiff of all files
noremap <Leader><Leader>fd :! meld $(pwd) &<CR>

" Run pylint on current file
noremap <Leader><Leader>pl :! pylint % <CR>


" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
      \ | wincmd p | diffthis
endif

" Autocommands
" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  autocmd!
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

