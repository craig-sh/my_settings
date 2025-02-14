return {
  { 'AndrewRadev/splitjoin.vim' },
  { 'mbbill/undotree' },
  { 'tpope/vim-repeat' },
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
          'filetype'
        }
      }
    }
  },
  {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    opts = {},
}
}
