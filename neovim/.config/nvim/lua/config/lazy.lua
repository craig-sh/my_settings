-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- General Settings
-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
--
vim.o.termguicolors = true
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

-- Always mistyping :w as :W...
vim.cmd([[ command! W w ]])


-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins/utility" },
    { import = "plugins/code_utility" },
    { import = "plugins/colorscheme" },
    { import = "plugins/git" },
    { import = "plugins/completion" },
    { import = "plugins/lsp" },
    { import = "plugins/keymaps" },
    { import = "plugins/orgmode" },
    { import = "plugins/snacks" },
    { import = "plugins/snippets" },
    { import = "plugins/term" },
    { import = "plugins/treesitter" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

