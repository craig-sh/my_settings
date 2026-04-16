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

-- When SSH'd into a remote, switch to OSC52 so regular y/p work via kitty
if vim.env.SSH_TTY then
  local osc52 = require('vim.ui.clipboard.osc52')
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = osc52.copy('+'),
      ['*'] = osc52.copy('*'),
    },
    paste = {
      ['+'] = osc52.paste('+'),
      ['*'] = osc52.paste('*'),
    },
  }
end

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

-- Autocmds
-- Autosave files in workspace
local function setup_autosave_timer()
  -- prevent duplicate timers
  if _G.autosave_timer then
    return
  end

  local interval = 300000 -- 5 minutes
  local target_dir = vim.fn.expand("~/Documents")

  local timer = vim.loop.new_timer()
  if not timer then
    vim.notify("Failed to create autosave timer", vim.log.levels.ERROR)
    return
  end

  _G.autosave_timer = timer

  timer:start(interval, interval, vim.schedule_wrap(function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].modified then

        local name = vim.api.nvim_buf_get_name(buf)

        if name ~= "" and vim.startswith(name, target_dir) then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent write")
          end)
        end
      end
    end
  end))
end

setup_autosave_timer()
--


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

