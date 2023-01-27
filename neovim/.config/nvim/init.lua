-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

local use = require('packer').use
require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package manager
  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    },
  }

  use 'SirVer/ultisnips'
  use { 'honza/vim-snippets', rtp = '.', requires = { 'SirVer/ultisnips' } }

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use { 'nvim-treesitter/nvim-treesitter-textobjects', requires = { 'nvim-treesitter/nvim-treesitter' } }
  use { 'nvim-treesitter/playground' }
  use 'nvim-orgmode/orgmode'

  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/cmp-nvim-lsp-signature-help'
  use 'ray-x/cmp-treesitter'
  use 'quangnguyen30192/cmp-nvim-ultisnips'
  use { 'andersevenrud/compe-tmux' }

  -- Performance issues with this
  -- use 'romgrk/nvim-treesitter-context'

  -- Movement
  use 'ggandor/lightspeed.nvim'

  -- Code feedback
  use 'tpope/vim-fugitive'
  use 'Shougo/echodoc.vim'
  use 'lifepillar/pgsql.vim'
  use 'psf/black'
  use { 'stsewd/isort.nvim', run = ':UpdateRemotePlugins' }
  use 'rhysd/git-messenger.vim'
  use 'Glench/Vim-Jinja2-Syntax'
  use 'lukas-reineke/indent-blankline.nvim'
  use { 'norcalli/nvim-colorizer.lua', config = function()
    require 'colorizer'.setup()
  end
  }

  -- Utilities
  use 'ojroques/nvim-osc52'
  use 'kosayoda/nvim-lightbulb'
  use 'stevearc/dressing.nvim'
  use 'kevinhwang91/nvim-bqf' -- Preview windows for qf list, etc
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  use({
    'mrjones2014/legendary.nvim',
    -- sqlite is only needed if you want to use frecency sorting
    requires = 'kkharji/sqlite.lua'
  })
  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable 'make' == 1 }
  use 'tpope/vim-sensible' -- Super common settings
  use 'tpope/vim-sleuth' --  Indentation settings
  use({
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end
  })
  use 'tpope/vim-repeat'
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require 'nvim-tree'.setup {
        hijack_directories = {
          enable = false,
          auto_open = false,
        }
      }
    end
  }
  use 'AndrewRadev/splitjoin.vim'
  use 'mbbill/undotree'
  use { 'glacambre/firenvim',
    run = function() vim.fn['firenvim#install'](0) end
  }
  use 'folke/which-key.nvim'
  use 'voldikss/vim-floaterm'
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }
  -- use 'justinmk/vim-dirvish'

  -- Visuals
  use {
    'lewis6991/gitsigns.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    },
  }
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup({
      })
    end
  }
  use {
    'hoob3rt/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use 'dbinagi/nomodoro'
  use 'rcarriga/nvim-notify'
  use { 'dracula/vim', as = 'dracula' }
  --use 'joshdick/onedark.vim'
  use 'navarasu/onedark.nvim'

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})

-- Diable netrw
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- Do this because we're getting errors with netrw
vim.cmd([[ let loaded_netrwPlugin = 1 ]])
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
-- vim.o.termguicolors = true
-- vim.g.onedark_terminal_italics = 1
-- vim.cmd [[colorscheme onedark]]
require('onedark').setup {
  toggle_style_key = '<leader>cs',
}
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

-- snips
vim.g.UltiSnipsExpandTrigger = '<C-k>'
vim.g.UltiSnipsJumpForwardTrigger = '<C-k>'
vim.g.UltiSnipsJumpBackwardTrigger = '<c-b>'
vim.g.UltiSnipsSnippetDirectories = { 'UltiSnips', 'mysnips' }

local l_opts = { noremap = true }
require('legendary').setup({
  keymaps = {
    { '<Leader>ts', ':Telescope treesiter<CR>', desc = 'Treesitter symbols', opts = l_opts },
    { '<Leader>tt', ':Telescope lsp_dynamic_workspace_symbols<CR>', desc = 'LSP Workspace symbols', opts = l_opts },
    { '<Leader>tw', ':Telescope treesiter<CR>', desc = 'LSP References', opts = l_opts },
    { '<Leader>m', ':Telescope lsp_document_symbols<CR>', desc = 'LSP Document Symbols', opts = l_opts },

    { '<Leader>ca', vim.lsp.buf.code_action, desc = 'Code Action', opts = l_opts },
    --{ '<Leader>cr', ':Telescope lsp_range_code_actions<CR>', desc = '', opts = l_opts },
    --
    { '<Leader>b', ':Telescope buffers<CR>', desc = 'Select buffer', opts = l_opts },
    { '<Leader>l', ':Legendary<CR>', desc = 'Legend', opts = l_opts },
    { '<Leader>ff', ':Telescope live_grep<CR>', desc = 'Grep for text', opts = l_opts },
    { '<Leader>fw', ':Telescope grep_string<CR>', desc = 'Grep for word under cursor', opts = l_opts },
    { '<Leader>fr', ':Telescope resume<CR>', desc = 'Resume most recect telescope search', opts = l_opts },
    { '<Leader>gg', ':Telescope git_status<CR>', desc = 'Find modified git files', opts = l_opts },
    { '<C-l>', ':Telescope find_files<CR>', desc = 'Find file', opts = l_opts },

    { '<F3>', '::NvimTreeFindFileToggle<CR>', desc = 'Tree finder', opts = l_opts },
    { '<Leader>ev', ':e $MYVIMRC<CR>', desc = 'Edit nvim config', opts = l_opts },
    { '<Leader>sv', ':source $MYVIMRC<CR>', desc = 'Source nvim config', opts = l_opts },

    { '<Leader>cf', [[:let @+=expand("%")<CR>]], desc = 'Copy relative path of file', opts = l_opts },
    { '<Leader>pwd', ':! pwd<CR>', desc = 'Print the pwd', opts = l_opts },
    { '<Leader>ss', ':syntax sync fromstart<CR>', desc = 'Resync syntax', opts = l_opts },

    { '<Leader><Leader>dt', [[<C-R>=strftime('%Y%m%d')<CR>]], desc = 'Insert current date', opts = l_opts, mode = 'i' },
    { '<Leader><Leader>dd', ':! meld % &<CR>', desc = 'Git current file diff', opts = l_opts },

    { '<Leader><Leader>fd', ':! meld $(pwd) &<CR>', desc = 'Git working tree diff', opts = l_opts },
    { '<Leader><Leader>fm', ':! git dirdiff master &<CR>', desc = 'Git diff against master', opts = l_opts },

    { '<Leader><Leader>pl', ':! pylint %<CR>', desc = 'Pylint', opts = l_opts },
    { '<Leader><Leader>pf', '::! pyflakes %<CR>', desc = 'Pyflakes', opts = l_opts },
    { '<Leader><Leader>mp', '::! mypy % --follow-imports=silent<CR> %<CR>', desc = 'mp', opts = l_opts },
    { '<Leader><Leader>pc', ':!pre-commit run --file %<CR>', desc = 'Run pre-commit on current file', opts = l_opts },


    -- Gitsigns
    { '<Leader>hs', ':lua require"gitsigns".stage_hunk()<CR>', desc = 'Stage hunk', opts = l_opts },
    { '<Leader>hs', ':lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>', desc = 'Stage hunk',
      opts = l_opts, mode = 'v' },
    { '<Leader>hu', ':lua require"gitsigns".undo_stage_hunk()<CR>', desc = 'Undo stage hunk', opts = l_opts },
    { '<Leader>hr', ':lua require"gitsigns".reset_hunk()<CR>', desc = 'Reset hunk', opts = l_opts },
    { '<Leader>hr', ':lua require"gitsigns".reset_hunk()<CR>', desc = 'Reset hunk', opts = l_opts, mode = 'v' },
    { '<Leader>hR', ':lua require"gitsigns".reset_buffer()<CR>', desc = 'Reset buffer', opts = l_opts },
    { '<Leader>hp', ':lua require"gitsigns".preview_hunk()<CR>', desc = 'Preview hunk', opts = l_opts },
    { '<Leader>hb', ':lua require"gitsigns".blame_line()<CR>', desc = 'Blame line', opts = l_opts },
    { '<Leader>hS', ':lua require"gitsigns".stage_buffer()<CR>', desc = 'Stage buffer', opts = l_opts },
    { '<Leader>hU', ':lua require"gitsigns".reset_buffer_index()<CR>', desc = 'Reset buffer index', opts = l_opts },


    { 'jj', '<Esc>', desc = 'Change to normal mode', mode = 'i', opts = { noremap = true, silent = true } },
    { '<F5>', [[%s/\s\+$//e]], desc = 'Remove trailing white space', opts = { noremap = true, expr = true } },

    { '<A-k>', ':wincmd k<CR>', desc = 'Window: Move up', opts = { noremap = true, silent = true } },
    { '<A-j>', ':wincmd j<CR>', desc = 'Window: Move down', opts = { noremap = true, silent = true } },
    { '<A-h>', ':wincmd h<CR>', desc = 'Window: Move left', opts = { noremap = true, silent = true } },
    { '<A-l>', ':wincmd l<CR>', desc = 'Window: Move right', opts = { noremap = true, silent = true } },


    { '<Esc>', [[<C-\><C-n>]], desc = 'Term: normal mode', opts = { noremap = true }, mode = 't' },
    { '<M-[>', '<Esc>', desc = 'Term: send esc', opts = { noremap = true }, mode = 't' },
    { '<C-v><Esc>', '<Esc>', desc = 'Term: send esc', opts = { noremap = true }, mode = 't' },
    { '<A-h>', [[<C-\><C-n><C-w>h]], desc = 'Term: (window) move left', opts = { noremap = true }, mode = 't' },
    { '<A-j>', [[<C-\><C-n><C-w>j]], desc = 'Term: (window) move down', opts = { noremap = true }, mode = 't' },
    { '<A-k>', [[<C-\><C-n><C-w>k]], desc = 'Term: (window) move up', opts = { noremap = true }, mode = 't' },
    { '<A-l>', [[<C-\><C-n><C-w>l]], desc = 'Term: (window) move right', opts = { noremap = true }, mode = 't' },

    { '<F12>', ':FloatermToggle<CR>', desc = 'Floaterm toggle', opts = { noremap = true, silent = true } },
    { '<F12>', [[<C-\><C-n>:FloatermToggle<CR>]], desc = 'Floaterm toggle', opts = { noremap = true, silent = true },
      mode = 't' },
    { '<Leader>y', require('osc52').copy_operator, opts = { expr = true } },
    { '<Leader>yy', '<Leader>y_', opts = { remap = true } },
    { '<Leader>y', require('osc52').copy_visual, mode = 'v' },

  },
  -- TODO autocommands
})



-- Always mistyping :w as :W...
vim.cmd([[ command! W w ]])

local gitsigns = require('gitsigns')
gitsigns.setup {
  keymaps = {
    -- Default keymap options
    noremap = true,
    ['n <C-j>'] = { expr = true, buffer = true,
      "&diff ? '<C-j>' : '<cmd>lua require\"gitsigns.actions\".next_hunk({wrap=false})<CR>'" },
    ['n <C-k>'] = { expr = true, buffer = true,
      "&diff ? '<C-k>' : '<cmd>lua require\"gitsigns.actions\".prev_hunk({wrap=false})<CR>'" },
  },
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
    delay = 2000,
  },
}

require('lualine').setup {
  options = {
    theme = 'onedark',
    component_separators = { '|', '|' },
    section_separators = { '', '' },
  },
  sections = {
      lualine_x = {
        require('nomodoro').status,
        'encoding',
        'fileformat',
        'filetype'
      }
  }
}

-- LSP

local actions = require('telescope.actions')
-- Global remapping
------------------------------
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
  pickers = {
    buffers = {
      sort_mru = true
    }
  },
  defaults = {
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
pcall(require('telescope').load_extension, 'fzf')


vim.diagnostic.config({
  virtual_text = {
    source = "always", -- Or "if_many"
  },
  float = {
    source = "always", -- Or "if_many"
  },
})


-- Setup mason so it can manage external tooling
require('mason').setup()

-- Ensure the servers above are installed
require('mason-lspconfig').setup()

local nvim_lsp = require 'lspconfig'
local legend = require 'legendary'
local on_attach = function(_, bufnr)
  local b_opts = { noremap = true, silent = true, buffer = bufnr }
  -- Mappings.
  legend.keymap({ 'gD', ':lua vim.lsp.buf.declaration()<CR>', opts = b_opts, desc = 'LSP goto declaration' })
  legend.keymap({ 'gd', ':lua vim.lsp.buf.definition()<CR>', opts = b_opts, desc = 'LSP goto definition' })
  legend.keymap({ 'gh', ':lua vim.lsp.buf.hover()<CR>', opts = b_opts, desc = 'LSP hover' })
  legend.keymap({ 'gi', ':lua vim.lsp.buf.implementation()<CR>', opts = b_opts, desc = 'LSP goto implementation' })
  legend.keymap({ 'gk', ':lua vim.lsp.buf.signature_help()<CR>', opts = b_opts, desc = 'LSP signature help' })
  legend.keymap({ '<space>wa', ':lua vim.lsp.buf.add_workspace_folder()<CR>', opts = b_opts,
    desc = 'LSP add workspace folder' })
  legend.keymap({ '<space>wr', ':lua vim.lsp.buf.remove_workspace_folder()<CR>', opts = b_opts,
    desc = 'LSP remove workspace folder' })
  legend.keymap({ '<space>wl', ':lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts = b_opts,
    desc = 'LSP list workspace folders' })
  legend.keymap({ 'gt', ':lua vim.lsp.buf.type_definition()<CR>', opts = b_opts, desc = 'LSP goto type definition' })
  legend.keymap({ 'gR', ':lua vim.lsp.buf.rename()<CR>', opts = b_opts, desc = 'LSP rename' })
  --legend.keymap({'gr', ':lua vim.lsp.buf.references()<CR>', opts= b_opts, desc=''})
  legend.keymap({ 'gr', ':TroubleToggle lsp_references<CR>', opts = b_opts, desc = 'LSP show references' })
  legend.keymap({ '<Leader>w', ':TroubleToggle<CR>', opts = b_opts, desc = 'LSP show issue window' })
  legend.keymap({ '<C-p>', ':lua vim.diagnostic.goto_prev()<CR>', opts = b_opts, desc = 'LSP prev diagnostic' })
  legend.keymap({ '<C-n>', ':lua vim.diagnostic.goto_next()<CR>', opts = b_opts, desc = 'LSP next diagnostic' })
  --legend.keymap({'<Leader>w', ':lua vim.lsp.diagnostic.set_loclist()<CR>', opts= b_opts, desc=''})
  --legend.keymap({'<Leader>w', ':TroubleToggle loclist<CR>', opts= b_opts, desc=''})
  legend.keymap({ 'gF', ':Format<CR>', opts = b_opts, desc = 'LSP format' })

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    if vim.lsp.buf.format then
      vim.lsp.buf.format()
    elseif vim.lsp.buf.formatting then
      vim.lsp.buf.formatting()
    end
  end, { desc = 'Format current buffer with LSP' })
end

-- Use a loop to conveniently both setup defined servers
-- and map buffer local keybindings when the language server attaches
-- Update commands
-- pip install 'python-lsp-server[all]' pylint pylsp-mypy pyls-isort pylsp-rope pyls-flake8 --upgrade --user
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local servers = { "hls", "pylsp", "rust_analyzer", "bashls", "vuels", "ansiblels" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            maxLineLength = 200,
          },
          flake8 = {
            maxLineLength = 200,
          }
        }
      }
    }
  }
end

-- Turn on status information
require('fidget').setup()

vim.notify = require("notify")
-- Poromodo timer
require('nomodoro').setup({
  on_work_complete = function()
    vim.cmd([[NomoStop]])
    vim.notify("Break time")
    vim.cmd([[silent ! spd-say "Break time"]])
    vim.cmd([[silent ! notify-send "Break Time" ]])
    --vim.cmd([[NomoBreak]])
  end,
  on_break_complete = function()
    vim.cmd([[NomoStop]])
    vim.notify("Back to Work")
    vim.cmd([[silent ! spd-say "Back to Work"]])
    vim.cmd([[silent ! notify-send "Back to work"]])
  end
})


-- Example custom configuration for lua
--
-- Make runtime files discoverable to the server

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')
require('lspconfig').sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {

        -- Tell the language server which version of Lua you're using (most likely LuaJIT)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = { library = vim.api.nvim_get_runtime_file('', true) },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = { enable = false },
    },
  },
}

require("which-key").setup {}

-- Compe setup
vim.o.completeopt = 'menuone,noselect'
local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  sources = {
    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'treesitter' },
    { name = 'buffer' },
    { name = 'nvim_lua' },
    { name = 'ultisnips' },
    {
      name = 'tmux',
      option = {
        all_panes = true,
      }
    },
    { name = 'orgmode' },
  },
  mapping = {
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm(),
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

-- Use buffer source for `/`.
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

require('orgmode').setup_ts_grammar()

require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { 'org' }, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  ensure_installed = { 'org', 'python', 'bash', 'vim', 'lua', 'javascript', 'sql', 'haskell' },
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
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",

      },
    },
  },
}

require('orgmode').setup({
  org_agenda_files = { '~/Documents/org/*' },
  org_default_notes_file = '~/Documents/org/refile.org',
})

require('nvim-lightbulb').setup({autocmd = {enabled = true}})

-- autocommands
--https://old.reddit.com/r/neovim/comments/p5is1h/how_to_open_a_file_in_the_last_place_you_editied/
-- This function is taken from https://github.com/norcalli/nvim_utils
local function nvim_create_augroups(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup ' .. group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten { 'autocmd', def }, ' ')
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

]])

vim.g.firenvim_config = {
  globalSettings = {
    alt = 'all',
  },
  localSettings = {
    ['.*'] = {
      cmdline = 'nvim',
      priority = 0,
      selector = 'textarea',
      takeover = 'never',
    },
  }
}
