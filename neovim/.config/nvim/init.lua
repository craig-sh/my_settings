-- Test message
-- Install lazy
vim.o.termguicolors = true
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      -- Useful status updates for LSP
      'j-hui/fidget.nvim',
    },
  },

  {
    'j-hui/fidget.nvim',
    opts = {}
  },
  'SirVer/ultisnips',
  {
    'honza/vim-snippets',
    dependencies = { 'SirVer/ultisnips' },
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/custom-rtp")
    end
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate'
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = {
      'nvim-treesitter/nvim-treesitter'
    }
  },
  'nvim-treesitter/playground',
  'nvim-orgmode/orgmode',

  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-nvim-lua',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-nvim-lsp-signature-help',
  'ray-x/cmp-treesitter',
  'quangnguyen30192/cmp-nvim-ultisnips',
  'andersevenrud/compe-tmux',

  -- Performance issues with this
  -- 'romgrk/nvim-treesitter-context'

  -- Movement
  'ggandor/leap.nvim',

  -- Code feedback
  'tpope/vim-fugitive',
  'Shougo/echodoc.vim',
  'lifepillar/pgsql.vim',
  --'psf/black',
  'rhysd/git-messenger.vim',
  'Glench/Vim-Jinja2-Syntax',
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {},
    config = function()
      require("ibl").setup()
      end
  },
  { 'norcalli/nvim-colorizer.lua', config = true },

  -- Utilities
  'ojroques/nvim-osc52',
  {
    'kosayoda/nvim-lightbulb',
    config = true,
    opts = {
      autocmd = {
        enabled = true }
    }
  },
  'stevearc/dressing.nvim',
  'kevinhwang91/nvim-bqf', -- Preview windows for qf list, etc
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  {
    'mrjones2014/legendary.nvim',
    -- sqlite is only needed if you want to use frecency sorting
    dependencies = 'kkharji/sqlite.lua'
  },
  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = vim.fn.executable 'make' == 1
  },
  'tpope/vim-sensible', -- Super common settings
  'tpope/vim-sleuth',   --  Indentation settings
  {
    "kylechui/nvim-surround",
    config = true
  },
  'tpope/vim-repeat',
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = 'kyazdani42/nvim-web-devicons',
    config = true,
    opts = {
      hijack_directories = {
        enable = false,
        auto_open = false,
      }
    }
  },
  'AndrewRadev/splitjoin.vim',
  'mbbill/undotree',
  {
    'glacambre/firenvim',
    lazy = not vim.g.started_by_firenvim,
    build = function() vim.fn['firenvim#install'](0) end
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {}
  },
  { 'numToStr/Comment.nvim', opts = {} },
  'voldikss/vim-floaterm',
  { 'sindrets/diffview.nvim',      dependencies = 'nvim-lua/plenary.nvim' },
  --
  -- Visuals
  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
  },
  {
    "folke/trouble.nvim",
    dependencies = "kyazdani42/nvim-web-devicons",
    opts = {}
  },
  {
    'hoob3rt/lualine.nvim',
    dependencies = 'kyazdani42/nvim-web-devicons'
  },
  'dbinagi/nomodoro',
  'rcarriga/nvim-notify',
  { 'dracula/vim', name = 'dracula' },
  'navarasu/onedark.nvim',
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^4.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  }
  --'joshdick/onedark.vim'
  --'folke/tokyonight.nvim'
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
vim.o.backupdir = '/home/craig/nvimtmp//'
vim.o.directory = '/home/craig/nvimtmp//'
vim.o.undodir = '/home/craig/.nvimundo'
vim.o.inccommand = 'split'
vim.o.wildoptions = 'pum'
vim.o.pumblend = 20
vim.o.clipboard = 'unnamedplus'
vim.o.mouse = 'a'

vim.o.history = 1000   -- lines of command line history
vim.o.ruler = true     -- show the cursor position all the time
vim.o.showcmd = true   -- display incomplete commands
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
-- vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

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
--vim.cmd[[colorscheme tokyonight]]

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

-- snips. Don't set keymaps here, set them in cmp instead. Even when there are enabled
-- there are issues with hitting Tab
-- vim.g.UltiSnipsExpandTrigger = '<C-k>'
-- vim.g.UltiSnipsJumpForwardTrigger = '<C-k>'
-- vim.g.UltiSnipsJumpBackwardTrigger = '<c-b>'
vim.g.UltiSnipsSnippetDirectories = { 'UltiSnips', 'mysnips' }
require('leap').add_default_mappings()
-- https://github.com/ggandor/leap.nvim#faq
-- Disablee the x/X mappings in leap
vim.keymap.del({'x', 'o'}, 'x')
vim.keymap.del({'x', 'o'}, 'X')
--
local l_opts = { noremap = true }
require('legendary').setup({
  keymaps = {
    {
      '<Leader>ts',
      ':Telescope treesiter<CR>',
      desc = 'Treesitter symbols',
      opts =
          l_opts
    },
    {
      '<Leader>tt',
      ':Telescope lsp_dynamic_workspace_symbols<CR>',
      desc = 'LSP Workspace symbols',
      opts =
          l_opts
    },
    {
      '<Leader>tw',
      ':Telescope treesiter<CR>',
      desc = 'LSP References',
      opts =
          l_opts
    },
    {
      '<Leader>m',
      ':Telescope lsp_document_symbols<CR>',
      desc = 'LSP Document Symbols',
      opts =
          l_opts
    },
    {
      '<Leader>ca',
      vim.lsp.buf.code_action,
      desc = 'Code Action',
      opts =
          l_opts
    },
    --{ '<Leader>cr', ':Telescope lsp_range_code_actions<CR>', desc = '', opts = l_opts },
    --
    {
      '<Leader>b',
      ':Telescope buffers<CR>',
      desc = 'Select buffer',
      opts =
          l_opts
    },
    {
      '<Leader>l',
      ':Legendary<CR>',
      desc = 'Legend',
      opts =
          l_opts
    },
    {
      '<Leader>ff',
      ':Telescope live_grep<CR>',
      desc = 'Grep for text',
      opts =
          l_opts
    },
    {
      '<Leader>fw',
      ':Telescope grep_string<CR>',
      desc = 'Grep for word under cursor',
      opts =
          l_opts
    },
    {
      '<Leader>fr',
      ':Telescope resume<CR>',
      desc = 'Resume most recect telescope search',
      opts =
          l_opts
    },
    {
      '<Leader>gg',
      ':Telescope git_status<CR>',
      desc = 'Find modified git files',
      opts =
          l_opts
    },
    {
      '<C-l>',
      ':Telescope find_files<CR>',
      desc = 'Find file',
      opts =
          l_opts
    },
    {
      '<F3>',
      '::NvimTreeFindFileToggle<CR>',
      desc = 'Tree finder',
      opts =
          l_opts
    },
    {
      '<Leader>ev',
      ':e $MYVIMRC<CR>',
      desc = 'Edit nvim config',
      opts =
          l_opts
    },
    {
      '<Leader>sv',
      ':source $MYVIMRC<CR>',
      desc = 'Source nvim config',
      opts =
          l_opts
    },

    {
      '<Leader>cf',
      [[:let @+=expand("%")<CR>]],
      desc = 'Copy relative path of file',
      opts =
          l_opts
    },
    {
      '<Leader>pwd',
      ':! pwd<CR>',
      desc = 'Print the pwd',
      opts =
          l_opts
    },
    {
      '<Leader>ss',
      ':syntax sync fromstart<CR>',
      desc = 'Resync syntax',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>dt',
      [[<C-R>=strftime('%Y%m%d')<CR>]],
      desc = 'Insert current date',
      opts =
          l_opts,
      mode =
      'i'
    },
    {
      '<Leader><Leader>dd',
      ':! meld % &<CR>',
      desc = 'Git current file diff',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>fd',
      ':! meld $(pwd) &<CR>',
      desc = 'Git working tree diff',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>fm',
      ':! git dirdiff master &<CR>',
      desc = 'Git diff against master',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>pl',
      ':! pylint %<CR>',
      desc = 'Pylint',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>pf',
      '::! pyflakes %<CR>',
      desc = 'Pyflakes',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>mp',
      '::! mypy % --follow-imports=silent<CR> %<CR>',
      desc = 'mp',
      opts =
          l_opts
    },
    {
      '<Leader><Leader>pc',
      ':!pre-commit run --file %<CR>',
      desc = 'Run pre-commit on current file',
      opts =
          l_opts
    },

    -- Gitsigns
    {
      '<Leader>hs',
      ':lua require"gitsigns".stage_hunk()<CR>',
      desc = 'Stage hunk',
      opts =
          l_opts
    },
    {
      '<Leader>hs',
      ':lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
      desc = 'Stage hunk',
      opts = l_opts,
      mode = 'v'
    },
    {
      '<Leader>hu',
      ':lua require"gitsigns".undo_stage_hunk()<CR>',
      desc = 'Undo stage hunk',
      opts =
          l_opts
    },
    {
      '<Leader>hr',
      ':lua require"gitsigns".reset_hunk()<CR>',
      desc = 'Reset hunk',
      opts =
          l_opts
    },
    {
      '<Leader>hr',
      ':lua require"gitsigns".reset_hunk()<CR>',
      desc = 'Reset hunk',
      opts =
          l_opts,
      mode =
      'v'
    },
    {
      '<Leader>hR',
      ':lua require"gitsigns".reset_buffer()<CR>',
      desc = 'Reset buffer',
      opts =
          l_opts
    },
    {
      '<Leader>hp',
      ':lua require"gitsigns".preview_hunk()<CR>',
      desc = 'Preview hunk',
      opts =
          l_opts
    },
    {
      '<Leader>hb',
      ':lua require"gitsigns".blame_line()<CR>',
      desc = 'Blame line',
      opts =
          l_opts
    },
    {
      '<Leader>hS',
      ':lua require"gitsigns".stage_buffer()<CR>',
      desc = 'Stage buffer',
      opts =
          l_opts
    },
    {
      '<Leader>hU',
      ':lua require"gitsigns".reset_buffer_index()<CR>',
      desc = 'Reset buffer index',
      opts =
          l_opts
    },
    {
      'jj',
      '<Esc>',
      desc = 'Change to normal mode',
      mode = 'i',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<F5>',
      [[%s/\s\+$//e]],
      desc = 'Remove trailing white space',
      opts = {
        noremap = true, expr = true }
    },
    {
      '<A-k>',
      ':wincmd k<CR>',
      desc = 'Window: Move up',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<A-j>',
      ':wincmd j<CR>',
      desc = 'Window: Move down',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<A-h>',
      ':wincmd h<CR>',
      desc = 'Window: Move left',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<A-l>',
      ':wincmd l<CR>',
      desc = 'Window: Move right',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<Esc>',
      [[<C-\><C-n>]],
      desc = 'Term: normal mode',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<M-[>',
      '<Esc>',
      desc = 'Term: send esc',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<C-v><Esc>',
      '<Esc>',
      desc = 'Term: send esc',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<A-h>',
      [[<C-\><C-n><C-w>h]],
      desc = 'Term: (window) move left',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<A-j>',
      [[<C-\><C-n><C-w>j]],
      desc = 'Term: (window) move down',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<A-k>',
      [[<C-\><C-n><C-w>k]],
      desc = 'Term: (window) move up',
      opts = {
        noremap = true },
      mode =
      't'
    },
    {
      '<A-l>',
      [[<C-\><C-n><C-w>l]],
      desc = 'Term: (window) move right',
      opts = {
        noremap = true },
      mode =
      't'
    },

    {
      '<F12>',
      ':FloatermToggle<CR>',
      desc = 'Floaterm toggle',
      opts = {
        noremap = true, silent = true }
    },
    {
      '<F12>',
      [[<C-\><C-n>:FloatermToggle<CR>]],
      desc = 'Floaterm toggle',
      opts = { noremap = true, silent = true },
      mode = 't'
    },
    { '<Leader>y',  require('osc52').copy_operator, opts = { expr = true } },
    { '<Leader>yy', '<Leader>y_',                   opts = { remap = true } },
    { '<Leader>y',  require('osc52').copy_visual,   mode = 'v' },

  },
  -- TODO autocommands
})



-- Always mistyping :w as :W...
vim.cmd([[ command! W w ]])

local gitsigns = require('gitsigns')
gitsigns.setup {
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    -- Navigation
    map('n', '<C-j>', function()
      if vim.wo.diff then return '<C-j>' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '<C-k>', function()
      if vim.wo.diff then return '<C-k>' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })
  end,
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
  legend.keymap({
    '<space>wa',
    ':lua vim.lsp.buf.add_workspace_folder()<CR>',
    opts = b_opts,
    desc = 'LSP add workspace folder'
  })
  legend.keymap({
    '<space>wr',
    ':lua vim.lsp.buf.remove_workspace_folder()<CR>',
    opts = b_opts,
    desc = 'LSP remove workspace folder'
  })
  legend.keymap({
    '<space>wl',
    ':lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
    opts = b_opts,
    desc = 'LSP list workspace folders'
  })
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

local servers = { "hls", "pylsp", "rust_analyzer", "bashls", "volar", "ansiblels", "nixd" }
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
          },
          ruff = {
            enabled = true,
            lineLength = 200,
          }
        }
      },
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
require('lspconfig').lua_ls.setup {
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


-- Compe setup
vim.o.completeopt = 'menuone,noselect'
local cmp = require('cmp')
local cmp_ultisnips_mappings = require("cmp_nvim_ultisnips.mappings")
cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  sources = cmp.config.sources({
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
  }),
  mapping = {
    ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 'c' }),
    ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 'c' }),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm(),
    ["<C-k>"] = cmp.mapping(
      function(fallback)
        cmp_ultisnips_mappings.expand_or_jump_forwards(fallback)
      end,
      { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
    ),
    ["<C-j"] = cmp.mapping(
      function(fallback)
        cmp_ultisnips_mappings.jump_backwards(fallback)
      end,
      { "i", "s", --[[ "c" (to enable the mapping in command mode) ]] }
    ),
  },
}

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
--cmp.setup.cmdline({ '/', '?' }, {
--  mapping = cmp.mapping.preset.cmdline(),
--  sources = {
--    { name = 'buffer' }
--  }
--})
--
---- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
--cmp.setup.cmdline(':', {
--  mapping = cmp.mapping.preset.cmdline(),
--  sources = cmp.config.sources({
--    { name = 'path' }
--  }, {
--    { name = 'cmdline' }
--    ,{ name = 'orgmode' }
--  })
--})
--
require('orgmode').setup_ts_grammar()

require("nvim-treesitter.install").compilers = { require("tools").gcc }
require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = { 'org' }, -- Required since TS highlighter doesn't support all syntax features (conceal)
  },
  -- This will be handled by nixos now
  ensure_installed = { 'org', 'python', 'bash', 'vim', 'lua', 'javascript', 'sql', 'haskell', 'ssh_config', 'nix' },
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
  org_startup_indented = true,
  mappings = {
    org = {
      org_next_visible_heading = 'g}}',
      org_previous_visible_heading = 'g{{'
    }
  },
})

function UpdateMasonCustom()
  local venv = vim.fn.stdpath("data") .. "/mason/packages/python-lsp-server/venv"
  local job = require("plenary.job")

  job:new({
    command = venv .. "/bin/pip",
    args = {
      "install",
      "-U",
      "--disable-pip-version-check",
      "pylsp-mypy",
      "python-lsp-ruff",
    },
    cwd = venv,
    env = { VIRTUAL_ENV = venv },
    on_exit = function()
      vim.notify("Finished installing pylsp modules.")
    end,
    on_start = function()
      vim.notify("Installing pylsp modules...")
    end,
  }):start()
end

require('nvim-lightbulb').setup({ autocmd = { enabled = true } })

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
    { 'BufRead', '*', [[call setpos(".", getpos("'\""))]] },
  },
  lua_highlight = {
    { "TextYankPost", "*", [[silent! lua vim.highlight.on_yank() {higroup="IncSearch", timeout=400}]] },
  },
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
