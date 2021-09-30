local use = require('packer').use
require('packer').startup(function()
    use 'wbthomason/packer.nvim' -- Package manager

    use 'SirVer/ultisnips'
    use {'honza/vim-snippets', requires = { 'SirVer/ultisnips' } }

    use 'neovim/nvim-lspconfig'
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use {'nvim-treesitter/nvim-treesitter-textobjects', requires = { 'nvim-treesitter/nvim-treesitter' } }

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'quangnguyen30192/cmp-nvim-ultisnips'
    use { 'andersevenrud/compe-tmux', branch = 'cmp' }

    -- Performance issues with this
    -- use 'romgrk/nvim-treesitter-context'

    -- Movement
    use 'justinmk/vim-sneak'

    -- Code feedback
    use 'tpope/vim-fugitive'
    use 'liuchengxu/vista.vim'
    use 'pangloss/vim-javascript'
    use 'Shougo/echodoc.vim'
    use 'lifepillar/pgsql.vim'
    use 'psf/black'
    use {'stsewd/isort.nvim', run = ':UpdateRemotePlugins' }
    use 'rhysd/git-messenger.vim'
    use 'Glench/Vim-Jinja2-Syntax'
    use 'lukas-reineke/indent-blankline.nvim'


    -- Utilities
    use 'kevinhwang91/nvim-bqf' -- Preview windows for qf list, etc
    use 'nvim-lua/plenary.nvim'
    use 'nvim-telescope/telescope.nvim'
    use 'tpope/vim-sensible'   -- Super common settings
    use 'tpope/vim-sleuth' --  Indentation settings
    use 'tpope/vim-surround'
    use 'tpope/vim-repeat'
    use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
    use 'AndrewRadev/splitjoin.vim'
    use 'mbbill/undotree'
    use { 'glacambre/firenvim',
        run = function() vim.fn['firenvim#install'](0) end
    }
    use 'folke/which-key.nvim'
    use 'voldikss/vim-floaterm'
    use 'justinmk/vim-dirvish'

    -- DB
    use 'tpope/vim-dadbod'
    use 'kristijanhusak/vim-dadbod-ui'
    use 'kristijanhusak/vim-dadbod-completion'

    -- Visuals
    use 'nvim-lua/lsp-status.nvim'
    use {
      'lewis6991/gitsigns.nvim',
      requires = {
        'nvim-lua/plenary.nvim'
      },
    }
    use {
      'hoob3rt/lualine.nvim',
      requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }
    use {'dracula/vim', as = 'dracula'}
    use 'joshdick/onedark.vim'

    use 'svermeulen/vimpeccable'
  end)

-- Do this because we're getting errors with netrw
vim.cmd( [[ let loaded_netrwPlugin = 1 ]] )
-- Do we still need to set this?
-- vim.o.wildignore = { '*/tmp/*','*.so','*.swp','*.zip','.svn','.git','.hg','CVS','.bzr','*.pyc','*.pyo','*.exe','*.dll','*.obj','*.o','*.a','*.lib','*.so','*.dylib','*.ncb','*.sdf','*.suo','*.pdb','*.idb','.DS_Store','*.class','*.psd','*.db','*.sublime-workspace','*.min.js','*.~1~','*.~2~','*.~3~','*.~4~','*.~5~','tags','htmlcov' }
vim.cmd [[ set grepprg=rg\ --vimgrep ]]

vim.cmd(
[[
if ($VIRTUAL_ENV != '')
    let g:python3_host_prog=$VIRTUAL_ENV . '/bin/python'
elseif executable('pyenv')
    let g:python3_host_prog='python'
endif
]]
)

-- DBUI
vim.cmd([[ let g:db_ui_use_nerd_fonts = 1 ]])
vim.cmd([[ let g:db_ui_tmp_query_location = '~/queries' ]])
vim.cmd([[ autocmd Filetype sql nnoremap <Leader>W <Plug>(DBUI_SaveQuery) ]])
vim.cmd([[ autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]])

-- General Settings
vim.o.list = true
vim.o.undofile = true
vim.o.termguicolors = true
vim.o.backupdir = '/home/craig/nvimtmp//'
vim.o.directory = '/home/craig/nvimtmp//'
vim.o.undodir = '/home/craig/.nvimundo'
vim.o.inccommand = 'split'
vim.o.wildoptions = 'pum'
vim.o.pumblend = 20
vim.o.clipboard = 'unnamedplus'
vim.o.mouse = 'a'

vim.o.history = 1000 -- lines of command line history
vim.o.ruler = true -- show the cursor position all the time
vim.o.showcmd = true -- display incomplete commands
vim.o.incsearch = true -- do incremental searching
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.o.relativenumber = true
vim.o.number = true
vim.o.wrap = false
vim.o.hlsearch = true
vim.o.hidden = true -- Switch buffers without saving
vim.o.scrolloff = 5
vim.o.sidescrolloff = 15
vim.o.showmode = false -- for echodoc, also we display our mode in status line anyway

vim.o.autoindent = true
vim.o.smartindent = true

vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')
vim.o.background = 'dark'

--Set colorscheme (order is important here)
vim.o.termguicolors = true
vim.g.onedark_terminal_italics = 1
vim.cmd [[colorscheme onedark]]

vim.g.indentLine_char = '▏'

-- echodoc
vim.g.echodoc_enable_at_startup = 1

-- Floatterm
vim.g.floaterm_position = 'bottomright'
vim.g.floaterm_blend = 25
vim.cmd(
[[
hi FloatermNF guibg='#14151b'
hi FloatermBorderNF guibg='#14151b' guifg=green
]]
)

-- Vista
vim.g.vista_default_executive = 'nvim_lsp'

-- snips
vim.g.UltiSnipsExpandTrigger = '<C-k>'
vim.g.UltiSnipsJumpForwardTrigger = '<C-k>'
vim.g.UltiSnipsJumpBackwardTrigger = '<c-b>'
vim.g.UltiSnipsSnippetDirectories = {'UltiSnips', 'mysnips'}

-- vimp is shorthand for vimpeccable
local vimp = require('vimp')

vimp.imap('jj', '<Esc>')

vimp.nnoremap({'expr', 'silent'}, '<F5>', [[:let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>]])


vim.cmd([[
nnoremap <silent> <A-k> :wincmd k<CR>
nnoremap <silent> <A-j> :wincmd j<CR>
nnoremap <silent> <A-h> :wincmd h<CR>
nnoremap <silent> <A-l> :wincmd l<CR>
]])
--vimp.nnoremap({'expr', 'silent'}, '<A-k>', ':wincmd k<CR>')
--vimp.nnoremap({'expr', 'silent'}, '<A-j>', ':wincmd j<CR>')
--vimp.nnoremap({'expr', 'silent'}, '<A-h>', ':wincmd h<CR>')
--vimp.nnoremap({'expr', 'silent'}, '<A-l>', ':wincmd l<CR>')

-- Terminal mode:
vimp.tnoremap('<Esc>', [[<C-\><C-n>]])
vimp.tnoremap('<M-[>', '<Esc>')
vimp.tnoremap('<C-v><Esc>', '<Esc>')
vimp.tnoremap('<A-h>', [[<C-\><C-n><C-w>h]])
vimp.tnoremap('<A-j>', [[<C-\><C-n><C-w>j]])
vimp.tnoremap('<A-k>', [[<C-\><C-n><C-w>k]])
vimp.tnoremap('<A-l>', [[<C-\><C-n><C-w>l]])

vim.cmd([[
noremap  <silent> <F12>  :FloatermToggle<CR>
noremap! <silent> <F12>  <Esc>:FloatermToggle<CR>
tnoremap <silent> <F12>  <C-\><C-n>:FloatermToggle<CR>
]])
--vimp.nnoremap({'expr', 'silent'}, '<F12>', [[:FloatermToggle<CR>]])
--vimp.inoremap({'expr', 'silent'}, '<F12>', [[<Esc>:FloatermToggle<CR>]])
--vimp.tnoremap({'expr', 'silent'}, '<F12>', [[<C-\><C-n>:FloatermToggle<CR>]])

-- File navigation mappings

vimp.noremap('<Leader>tt', '<cmd>Telescope lsp_dynamic_workspace_symbols<CR>')
vimp.noremap('<Leader>ts', '<cmd>Telescope treesitter<CR>')
vimp.noremap('<Leader>tw', '<cmd>Telescope lsp_references<CR>')
vimp.noremap('<Leader>ca', '<cmd>Telescope lsp_code_actions<CR>')
vimp.noremap('<Leader>cr', '<cmd>Telescope lsp_range_code_actions<CR>')
vimp.noremap('<Leader>m', '<cmd>Telescope lsp_document_symbols<CR>')
vimp.noremap('<Leader>b', '<cmd>Telescope buffers<CR>')
vimp.noremap('<Leader>l', '<cmd>Telescope find_files<CR>')
-- noremap <Leader>g :GFiles?<CR>
vimp.noremap({ 'override' }, '<C-l>', '<cmd>Telescope find_files<CR>')

--vimp.nnoremap('<Leader>f', '<cmd>Telescope live_grep<CR>')
vimp.nnoremap('<Leader>ff', '<cmd>Telescope live_grep<CR>')
vimp.nnoremap('<Leader>fw', '<cmd>Telescope grep_string<CR>')

-- Always mistyping :w as :W...
vim.cmd([[ command! W w ]])

vimp.nmap('<F3>', ':NERDTreeToggle<CR>')
vimp.nmap('<F8>', ':Vista!!<CR>')

vimp.nnoremap('<Leader>ev', ':e $MYVIMRC<CR>')
vimp.nnoremap('<Leader>sv', ':source $MYVIMRC<CR>')
-- relative path (src/foo.txt)
vimp.nnoremap('<Leader>cf', [[:let @+=expand("%")<CR>]])
vimp.nnoremap('<Leader>pwd', ':! pwd<CR>')

vimp.nnoremap('<Leader>ss', ':syntax sync fromstart<CR>')

-- External shortcuts, start with <Leader><Leader>
-- make python tags
vimp.noremap('<Leader><Leader>mt', ':! ctags -R --languages=python<CR>')
-- insert the current datetime
vimp.imap('<Leader><Leader>dt', [[<C-R>=strftime('%Y%m%d')<CR>]])

-- diff of current file
vimp.noremap('<Leader><Leader>dd', ':! meld % &<CR>')

vimp.noremap('<Leader><Leader>fd', ':! meld $(pwd) &<CR>')
vimp.noremap('<Leader><Leader>fm', ':! git dirdiff master &<CR>')

-- Run pylint on current file
vimp.noremap('<Leader><Leader>pl', ':! pylint % <CR>')
vimp.noremap('<Leader><Leader>pf', '::! pyflakes % <CR>')
vimp.noremap('<Leader><Leader>mp', '::! mypy % --follow-imports=silent<CR>')



local gitsigns = require('gitsigns')
gitsigns.setup {
  keymaps = {
    -- Default keymap options
    noremap = true,

    ['n <C-j>'] = { expr = true, buffer = true, "&diff ? '<C-j>' : '<cmd>lua require\"gitsigns.actions\".next_hunk({wrap=false})<CR>'"},
    ['n <C-k>'] = { expr = true, buffer = true, "&diff ? '<C-k>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk({wrap=false})<CR>'"},

    ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
    ['v <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
    ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
    ['v <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
    ['n <leader>hR'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
    ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
    ['n <leader>hS'] = '<cmd>lua require"gitsigns".stage_buffer()<CR>',
    ['n <leader>hU'] = '<cmd>lua require"gitsigns".reset_buffer_index()<CR>',
  },
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 2000,
  },
}

require('lualine').setup{
  options = {
    theme = 'onedark',
    component_separators = {'|', '|'},
    section_separators = {'', ''},
  },
  sections = {
    lualine_b = {'b:gitsigns_head', 'b:gitsigns_status'},
    lualine_c = {'filename',  require'lsp-status'.status},
  }
}

-- LSP

local actions = require('telescope.actions')
-- Global remapping
------------------------------
require('telescope').setup{
  pickers = {
    buffers = {
      sort_lastused = true
    }
  },
  defaults = {
    layout_strategy = "vertical",
    layout_config = {
       vertical = {
         preview_height = 0.5, -- adjust to taste
      }
    },
    mappings = {
      i = {
        ["<C-e>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-q>"] = actions.close,
        ["<C-Down>"] = actions.cycle_history_next,
        ["<C-Up>"] = actions.cycle_history_prev,
      },
      n = {
        ["<C-e>"] = actions.send_to_qflist + actions.open_qflist,
        ["<C-q>"] = actions.close
      }
    },
  }
}

local lsp_status = require('lsp-status')
lsp_status.register_progress()

local nvim_lsp = require'lspconfig'

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = {
    'documentation',
    'detail',
    'additionalTextEdits',
  }
}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gk', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gR', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<C-p>', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', '<C-n>', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<Leader>w', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "gF", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "gF", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
  lsp_status.on_attach(client)
end

-- Use a loop to conveniently both setup defined servers 
-- and map buffer local keybindings when the language server attaches
capabilities = vim.tbl_extend('keep', capabilities or {}, lsp_status.capabilities)
local servers = { "pyright", "rls", "bashls", "vuels" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

require("which-key").setup {}


vim.o.completeopt = 'menuone,noselect'
-- Compe setup
local cmp = require('cmp')
cmp.setup {
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'ultisnips' },
    {
      name = 'tmux',
      opts = {
        all_panes = true,
      }
    },
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      --elseif luasnip.expand_or_jumpable() then
      --  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
      --elseif luasnip.jumpable(-1) then
      --  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
}

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
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim 
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

      },
    },
  },
}


-- autocommands
--https://old.reddit.com/r/neovim/comments/p5is1h/how_to_open_a_file_in_the_last_place_you_editied/
-- This function is taken from https://github.com/norcalli/nvim_utils
function nvim_create_augroups(definitions)
    for group_name, definition in pairs(definitions) do
        vim.api.nvim_command('augroup '..group_name)
        vim.api.nvim_command('autocmd!')
        for _, def in ipairs(definition) do
            local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
            vim.api.nvim_command(command)
        end
        vim.api.nvim_command('augroup END')
    end
end

local autocmds = {
  restore_cursor = {
      { 'BufRead', '*', [[call setpos(".", getpos("'\""))]] };
  };
  lua_highlight = {
      { "TextYankPost", "*", [[silent! lua vim.highlight.on_yank() {higroup="IncSearch", timeout=400}]] };
  };
}
nvim_create_augroups(autocmds)


-- Firenvim
vim.cmd([[
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

endif

" Statusline
function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

]])

vim.g.firenvim_config = {
  globalSettings = {
    alt = 'all',
  },
  localSettings = {
    ['.*'] = {
      cmdline = 'nvim',
      priority =  0,
      selector = 'textarea',
      takeover = 'never',
    },
  }
}
