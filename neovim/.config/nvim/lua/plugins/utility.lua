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
      -- Highly recommended: define a preview filter to reduce visual noise
      -- and the blinking effect after the first keypress
      -- (`:h leap.opts.preview`). You can still target any visible
      -- positions if needed, but you can define what is considered an
      -- exceptional case.
      -- Exclude whitespace and the middle of alphabetic words from preview:
      --   foobar[baaz] = quux
      --   ^----^^^--^^-^-^--^
      require('leap').opts.preview = function (ch0, ch1, ch2)
        return not (
          ch1:match('%s')
          or (ch0:match('%a') and ch1:match('%a') and ch2:match('%a'))
        )
      end

      -- Define equivalence classes for brackets and quotes, in addition to
      -- the default whitespace group:
      require('leap').opts.equivalence_classes = {
        ' \t\r\n', '([{', ')]}', '\'"`'
      }

      -- Use the traversal keys to repeat the previous motion without
      -- explicitly invoking Leap:
      --
      --require('leap.user').set_repeat_keys('<enter>', '<backspace>')


      vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
      vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')
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
    priority = 10, -- Needs to be a really low priority, to catch others plugins keybindings.
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
  },
  {
    "hat0uma/csvview.nvim",
    ---@module "csvview"
    ---@type CsvView.Options
    opts = {
      parser = { comments = { "#", "//" } },
      keymaps = {
        -- Text objects for selecting fields
        textobject_field_inner = { "if", mode = { "o", "x" } },
        textobject_field_outer = { "af", mode = { "o", "x" } },
        -- Excel-like navigation:
        -- Use <Tab> and <S-Tab> to move horizontally between fields.
        -- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
        -- Note: In terminals, you may need to enable CSI-u mode to use <S-Tab> and <S-Enter>.
        jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
        jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
        jump_next_row = { "<Enter>", mode = { "n", "v" } },
        jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
      },
    },
    cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  }
}
