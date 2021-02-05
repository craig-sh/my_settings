""" External prorams to install
" 1. exuberant ctags
" 2. ripgrep or ag
" 3. pip install --upgrade python-language-server pynvim msgpack pyls-isort pyls-black pyflakes
" 4. Rust lsp - rustup update && rustup component add rls rust-analysis rust-src
" 5. Vue lsp - :LspInstall vuels or npm install -g vls

""" Plugins
call plug#begin()
Plug 'Shougo/neosnippet'
Plug 'neovim/nvim-lspconfig'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/deoplete-lsp'
" deoplete source for completion of tmux words
Plug 'wellle/tmux-complete.vim'
Plug 'nvim-treesitter/nvim-treesitter'

" Performance issues with this
"Plug 'romgrk/nvim-treesitter-context'

" Movement
Plug 'Lokaltog/vim-easymotion'

" Code feedback
Plug 'mhinz/vim-signify'
Plug 'tpope/vim-fugitive'
Plug 'liuchengxu/vista.vim'
Plug 'jeetsukumaran/vim-pythonsense' " TODO remove and map using tree-sitter context
Plug 'pangloss/vim-javascript'
Plug 'Shougo/echodoc.vim'
Plug 'lifepillar/pgsql.vim'
Plug 'psf/black'
Plug 'rhysd/git-messenger.vim'
Plug 'Glench/Vim-Jinja2-Syntax'


" Utilities
Plug 'kevinhwang91/nvim-bqf' " Preview windows for qf list, etc
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-sensible' " Super common settings
Plug 'tpope/vim-sleuth'  " Indentation settings TODO this might be solved with tree-sitter indentation
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'AndrewRadev/splitjoin.vim'
Plug 'mbbill/undotree'
Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
Plug 'voldikss/vim-floaterm'

" Visuals
Plug 'nvim-lua/lsp-status.nvim'
Plug 'itchyny/lightline.vim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'joshdick/onedark.vim'
Plug 'ryanoasis/vim-devicons' " README says to load this plugin as the last one
call plug#end()

set wildignore+=*/tmp/*,*.so,*.swp,*.zip,.svn,.git,.hg,CVS,.bzr,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.ncb,*.sdf,*.suo,*.pdb,*.idb,.DS_Store,*.class,*.psd,*.db,*.sublime-workspace,*.min.js,*.~1~,*.~2~,*.~3~,*.~4~,*.~5~,tags,htmlcov

if executable('rg')
  let grepprg = 'rg --vimgrep'
  " Ignore necessary files
  let $FZF_DEFAULT_COMMAND = 'rg --files --hidden --follow --glob "!.git/*" --glob "!.bzr/*"'
elseif executable('ag')
  let grepprg = 'ag --vimgrep'
endif

if ($VIRTUAL_ENV != '')
    let g:python3_host_prog=$VIRTUAL_ENV . '/bin/python'
elseif executable('pyenv')
    let g:python3_host_prog='python'
endif

""" General Settings
set list
set undofile
set termguicolors
set backupdir=~/nvimtmp//
set directory=~/nvimtmp//
set undodir=~/.nvimundo
set inccommand=split
set wildoptions=pum
set pumblend=20
set clipboard=unnamedplus
set mouse=a

set history=1000 " lines of command line history
set ruler " show the cursor position all the time
set showcmd " display incomplete commands
set incsearch " do incremental searching
set cursorline
set cursorcolumn
set relativenumber
set number
set nowrap
set hlsearch
set hidden " Switch buffers without saving
set scrolloff=5
set sidescrolloff=15
set noshowmode " for echodoc, also we display our mode in status line anyway

set autoindent
set smartindent
filetype plugin indent on


if &t_Co > 2 || has("gui_running")
  let g:python_highlight_space_errors=1
  let python_highlight_all=1
  let g:python_slow_sync=0
  syntax on
  set background=dark
  let g:onedark_terminal_italics=1
  if &diff
    " Its hard to read onedark's diff
    colorscheme dracula
  else
    colorscheme onedark
  endif
  set guifont=Fantasque\ Sans\ Mono:h16
endif

let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified', 'lsp_status' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
      \   'lsp_status': 'LspStatus'
      \ },
      \ }

""" echodoc
let g:echodoc_enable_at_startup = 1

"Floatterm
let g:floaterm_position = 'bottomright'
let g:floaterm_winblend = 25
"let g:floaterm_width = &columns " Take up full width of screen
"let g:floaterm_height = 0.4 * &lines " 40% of heigt
hi FloatermNF guibg='#14151b'
hi FloatermBorderNF guibg='#14151b' guifg=green

" Vista
let g:vista_default_executive = 'nvim_lsp'

""" Custom shortcuts
imap jj <Esc>
" Trim :railing whitespace from file
nnoremap <silent> <F5> :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>

" Terminal mode:
tnoremap <Esc> <C-\><C-n>
tnoremap <M-[> <Esc>
tnoremap <C-v><Esc> <Esc>
tnoremap <A-h> <c-\><c-n><c-w>h
tnoremap <A-j> <c-\><c-n><c-w>j
tnoremap <A-k> <c-\><c-n><c-w>k
tnoremap <A-l> <c-\><c-n><c-w>l

noremap  <silent> <F12>  :FloatermToggle<CR>
noremap! <silent> <F12>  <Esc>:FloatermToggle<CR>
tnoremap <silent> <F12>  <C-\><C-n>:FloatermToggle<CR>

" File navigation mappings
""""FZF""""

noremap <Leader>t :Tags<CR>
noremap <Leader>m :BTags<CR>
noremap <Leader>b :Buffers<CR>
noremap <Leader>l :Files<CR>
noremap <Leader>g :GFiles?<CR>
noremap <c-l> :Files<CR>
" Netrw will map refresh to c-l if we don't define it first
nnoremap <leader><leader>q <Plug>NetrwRefresh
if executable('rg')
  nnoremap <Leader>f :Rg<Space>
  nnoremap <Leader>fw :Rg <C-R><C-W><CR>
elseif executable('ag')
  nnoremap <Leader>f :Ag<Space>
  nnoremap <Leader>fw :Ag <C-R><C-W><CR>
endif

" Always mistyping :w as :W...
command! W w
nmap <C-j> <Plug>(signify-next-hunk)
nmap <C-k> <Plug>(signify-prev-hunk)

nmap <F3> :NERDTreeToggle<CR>
nmap <F8> :Vista!!<CR>

" Edit vimrc
nnoremap <Leader>ev :e $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>
" relative path (src/foo.txt)
nnoremap <Leader>cf :let @+=expand("%")<CR>
" PWD
nnoremap <Leader>pwd :! pwd<CR>

nnoremap <Leader>d :SignifyHunkDiff<CR>
nnoremap <Leader>du :SignifyHunkUndo<CR>

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
"noremap <Leader><Leader>d :! GTK_THEME=Adwaita:light meld % &<CR>
noremap <Leader><Leader>d :! meld % &<CR>

" blame of current file
noremap <Leader><Leader>gb :! smerge blame % <C-r>=line('.')<CR> &<CR>

" qdiff of all files
"noremap <Leader><Leader>fd :! GTK_THEME=Adwaita:light meld $(pwd) &<CR>
noremap <Leader><Leader>fd :! meld $(pwd) &<CR>
"noremap <Leader><Leader>fdm :! GTK_THEME=Adwaita:light git dirdiff master &<CR>
noremap <Leader><Leader>fdm :! git dirdiff master &<CR>

" Run pylint on current file
noremap <Leader><Leader>pl :! pylint % <CR>
noremap <Leader><Leader>pf :! pyflakes % <CR>
noremap <Leader><Leader>mp :! mypy % --follow-imports=silent<CR>


if exists('g:started_by_firenvim')
  " wrap is helpful in browser context
  set wrap

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
              \ 'cmdline': 'nvim',
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

au TextYankPost * silent! lua require'vim.highlight'.on_yank()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neosnippet
" disables all runtime snippets
let g:neosnippet#disable_runtime_snippets = {
\   '_' : 1,
\ }
" Snippet Settings
let g:neosnippet#snippets_directory = '~/my_settings/vim-snips/'

" Embedded syntax highlighting of vimscript for lua
let g:vimsyn_embed = 'l'

" fzf preview window to appear on top, toggle with ctrl-/
let g:fzf_preview_window = ['up:50%', 'ctrl-/']

"nvim lsp
lua << EOF
local lsp_status = require('lsp-status')
lsp_status.register_progress()

local nvim_lsp = require'lspconfig'

local attach_client = function(client)
    lsp_status.on_attach(client)
end

nvim_lsp.pyright.setup{
  on_attach=attach_client,
  capabilities = lsp_status.capabilities,
}

nvim_lsp.rls.setup{
  on_attach=attach_client,
  capabilities = lsp_status.capabilities,
}

nvim_lsp.bashls.setup{
  on_attach=attach_client,
  capabilities = lsp_status.capabilities,
}

nvim_lsp.vuels.setup{
  on_attach=attach_client,
  capabilities = lsp_status.capabilities,
}

EOF

" Statusline
function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif
  return ''
endfunction

" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gh     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gR    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> gF    <cmd>lua vim.lsp.buf.formatting()<CR>

"Diamove
"let g:lsp_diamove_disable_default_mapping = v:true
"nnoremap <silent> <C-n> <cmd>Dbelow<CR>
"nnoremap <silent> <C-p> <cmd>Dabove<CR>

nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_next { wrap = true }<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_prev { wrap = true }<CR>
nnoremap <Leader>w <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>

" completion
let g:deoplete#enable_at_startup = 1
" Bubble lsp completeions to the top
call deoplete#custom#source('lsp', 'rank', 9999)

" disable preview window
set completeopt-=preview

"""""""""""""
" Tree sitter
"
""""""""""""

lua << EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    use_languagetree = false, -- Use this to enable language injection (this is very unstable)
  },
  incremental_selection = {
   enable = true,
   keymaps = {
     init_selection = "<CR>",
     node_incremental = "<CR>",
     scope_incremental = "<C-s>",
     node_decremental = "<C-r>",
   },
  },
  indent = {
    enable = false
  },
}
EOF

