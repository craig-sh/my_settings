""" External prorams to install
" 1. exuberant ctags
" 2. ripgrep or ag
" 3. Need nodem, yarn,npm for CoC

""" Plugins
call plug#begin()
if has('nvim')
  Plug 'Shougo/neosnippet'
  " Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
  " Need to run :CocInstall coc-neosnippet coc-python coc-tag coc-syntax coc-highlight coc-lists
  "Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'neovim/nvim-lsp'
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/deoplete-lsp'
  " deoplete source for completion of tmux words
  Plug 'wellle/tmux-complete.vim'
  Plug 'voldikss/vim-floaterm'
endif

" Movement
Plug 'Lokaltog/vim-easymotion'

" Code feedback
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'liuchengxu/vista.vim'
Plug 'vim-python/python-syntax'
Plug 'jeetsukumaran/vim-pythonsense'
Plug 'Shougo/echodoc.vim'
Plug 'lifepillar/pgsql.vim'
Plug 'psf/black'
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}

" Utilities

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-sensible' " Super common settings
Plug 'tpope/vim-sleuth'  " Indentation settings
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mbbill/undotree'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

" Visuals
Plug 'vim-airline/vim-airline'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'joshdick/onedark.vim'
call plug#end()

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags,htmlcov

if executable('rg')
  let grepprg = 'rg --vimgrep'
  " Ignore necessary files
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*" --glob "!.bzr/*"'
elseif executable('ag')
  let grepprg = 'ag --vimgrep'
endif
let g:python3_host_prog='/usr/bin/python'
""" General Settings
set list
set undofile
if has('nvim')
  set termguicolors
  set backupdir=~/nvimtmp//
  set directory=~/nvimtmp//
  set undodir=~/.nvimundo
  set inccommand=split
  set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50
    \,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor
    \,sm:block-blinkwait175-blinkoff150-blinkon175
  set wildoptions=pum
  set pumblend=20
  "set wildmenu
  "set wildmode=longest:list,full
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
    let g:onedark_terminal_italics=1
    if &diff
      " Its hard to read onedark's diff
      colorscheme dracula
    else
      colorscheme onedark
    endif
  endif
endif

""" Custom shortcuts
imap jj <Esc>
" Trim :railing whitespace from file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>

if has('nvim')
  " Terminal mode:
  tnoremap <Esc> <C-\><C-n>
  tnoremap <M-[> <Esc>
  tnoremap <C-v><Esc> <Esc>
  tnoremap <A-h> <c-\><c-n><c-w>h
  tnoremap <A-j> <c-\><c-n><c-w>j
  tnoremap <A-k> <c-\><c-n><c-w>k
  tnoremap <A-l> <c-\><c-n><c-w>l
endif

" File navigation mappings
""""FZF""""

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

  noremap <Leader>t :Tags<CR>
  noremap <Leader>m :BTags<CR>
  noremap <Leader>b :Buffers<CR>
  noremap <Leader>l :Files<CR>
  noremap <c-l> :Files<CR>
  " Netrw will map refresh to c-l if we don't define it first
  nnoremap <leader><leader>q <Plug>NetrwRefresh
  if executable('rg')
    nnoremap <Leader>f :Rg 
  elseif executable('ag')
    nnoremap <Leader>f :Ag 
  endif

  "Floatterm
  let g:floaterm_position = 'bottomleft'
  let g:floaterm_winblend = 10
  let g:floaterm_width = &columns " Take up full width of screen
  let g:floaterm_height = 0.4 * &lines " 40% of heigt
  let g:floaterm_background = '#14151b'
  noremap  <silent> <F12>  :FloatermToggle<CR>
  noremap! <silent> <F12>  <Esc>:FloatermToggle<CR>
  tnoremap <silent> <F12>  <C-\><C-n>:FloatermToggle<CR>

" make python tags
noremap <Leader><Leader>mt :! ctags -R --languages=python<CR>
" insert the current datetime
imap <Leader><Leader>dt <C-R>=strftime('%Y%m%d')<CR>
" relative path (src/foo.txt)
nnoremap <Leader>cf :let @+=expand("%")<CR>
" PWD
nnoremap <Leader>pwd :! pwd<CR>

nnoremap <Leader>d :SignifyHunkDiff<CR>
nnoremap <Leader>du :SignifyHunkUndo<CR>

nnoremap <Leader>ss :syntax sync fromstart<CR>

" Always mistyping :w as :W...
command! W w
nmap <C-j> <Plug>(signify-next-hunk)
nmap <C-k> <Plug>(signify-prev-hunk)

" Semshi
let g:semshi#simplify_markup = v:false

let g:black_virtualenv = '/home/craig/.local/pipx/venvs/black'

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


if exists('g:started_by_firenvim')
  " Mapping to escape firenvims focus in browser
  nnoremap <Esc><Esc> :call firenvim#focus_page()<CR>
  " Autosync firenvim buffer
  let g:dont_write = v:false
  function! My_Write(timer) abort
          let g:dont_write = v:false
          write
  endfunction

  function! Delay_My_Write() abort
          if g:dont_write
                  return
          end
          let g:dont_write = v:true
          call timer_start(10000, 'My_Write')
  endfunction

  au TextChanged * ++nested call Delay_My_Write()
  au TextChangedI * ++nested call Delay_My_Write()

  let g:firenvim_config = {
      \ 'globalSettings': {
          \ 'alt': 'all',
      \  },
      \ 'localSettings': {
          \ '.*': {
              \ 'cmdline': 'neovim',
              \ 'priority': 0,
              \ 'selector': 'textarea',
              \ 'takeover': 'never',
          \ },
      \ }
  \ }
endif

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neosnippet
if has('nvim')
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
endif

"nvim lsp
if has('nvim')
lua << EOF
local nvim_lsp = require'nvim_lsp'
nvim_lsp.pyls.setup{
    root_dir = nvim_lsp.util.root_pattern('.git');
}

-- Show any lsp diagnostics in qflist
do
  local method = 'textDocument/publishDiagnostics'
  local default_callback = vim.lsp.callbacks[method]
  vim.lsp.callbacks[method] = function(err, method, result, client_id)
    default_callback(err, method, result, client_id)
    if result and result.diagnostics then
      for _, v in ipairs(result.diagnostics) do
        v.uri = v.uri or result.uri
      end
      vim.lsp.util.set_qflist(result.diagnostics)
    end
  end
end
EOF

  nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> gh     <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <silent> K <cmd>lua vim.lsp.buf.signature_help()<CR>
  nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
  nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>

  " Use LSP omni-completion in Python files.
  autocmd Filetype python setlocal omnifunc=v:lua.vim.lsp.omnifunc
  " completion
  let g:deoplete#enable_at_startup = 1

  " disable preview window
  set completeopt-=preview
endif

" Coc
if !has('nvim')
  let g:airline#extensions#coc#enabled = 1
  " Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
  " Coc only does snippet and additional edit on confirm.
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

  " Use `[c` and `]c` for navigate diagnostics
  nmap <silent> [c <Plug>(coc-diagnostic-prev)
  nmap <silent> ]c <Plug>(coc-diagnostic-next)

  " Remap keys for gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)


  " Use K for show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if &filetype == 'vim'
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Remap for rename current word
  nmap <leader>rn <Plug>(coc-rename)
  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  vmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap for do codeAction of current line
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Fix autofix problem of current line
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Use `:Format` for format current buffer
  command! -nargs=0 Format :call CocAction('format')

  " Use `:Fold` for fold current buffer
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)

  " You will have bad experience for diagnostic messages when it's default 4000.
  set updatetime=300
  " don't give |ins-completion-menu| messages.
  set shortmess+=c
  " always show signcolumns
  set signcolumn=yes

  set cmdheight=2
endif

""" Code Outline
" nmap <F8> :TagbarToggle<CR>
" let g:tagbar_vertical = 30
" let g:tagbar_left = 1
" nmap <F3> :NERDTreeToggle<CR>
nmap <F8> :Vista!!<CR>


""" vim-airline
let g:airline_powerline_fonts = 1
let g:airline_theme='onedark'
set laststatus=2

""" echodoc
set noshowmode
let g:echodoc_enable_at_startup = 1

