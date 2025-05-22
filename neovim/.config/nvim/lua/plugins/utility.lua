return {
  { 'AndrewRadev/splitjoin.vim' },
  { 'mbbill/undotree' },
  { 'tpope/vim-repeat' },
  {
      "3rd/image.nvim",
      build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
      opts = {
          processor = "magick_rock",
      }
  },
  { 'tpope/vim-sleuth' }, --  Indentation settings
  { 'norcalli/nvim-colorizer.lua', opts = {} },
  { 'farmergreg/vim-lastplace' },
  { 'ggandor/leap.nvim',
    config = function ()
      require('leap').create_default_mappings()
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    opts = {
      hijack_directories = {
        enable = false,
        auto_open = false,
      }
    },
    keys = {
      '<F3>',
      '<cmd>NvimTreeFindFileToggle<cr>',
      desc = 'NvimTree',
    }
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'onedark',
        component_separators = { '|', '|' },
        section_separators = { '', '' },
      },
      sections = {
        lualine_x = {
          'encoding',
          'fileformat',
          'lsp_status',
          'filetype'
        }
      }
    }
  },
  {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  }
}
