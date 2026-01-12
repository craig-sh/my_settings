return {
  { 'numToStr/Comment.nvim', opts = {} },
  { "nvim-tree/nvim-web-devicons", opts = {} },
  {
      "kylechui/nvim-surround",
      event = "VeryLazy",
      opts = {},
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python")({
            runner = "pytest",
            dap = { justMyCode = true },
          }),
        },
      })
    end,
  },
  --{
  --  'saghen/blink.pairs',
  --  version = '*', -- (recommended) only required with prebuilt binaries

  --  -- download prebuilt binaries from github releases
  --  dependencies = 'saghen/blink.download',
  --  -- OR build from source, requires nightly:
  --  -- https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  --  -- build = 'cargo build --release',
  --  -- If you use nix, you can build from source using latest nightly rust with:
  --  -- build = 'nix run .#build-plugin',

  --  --- @module 'blink.pairs'
  --  --- @type blink.pairs.Config
  --  opts = {
  --    mappings = {
  --      -- you can call require("blink.pairs.mappings").enable()
  --      -- and require("blink.pairs.mappings").disable()
  --      -- to enable/disable mappings at runtime
  --      enabled = true,
  --      cmdline = true,
  --      -- or disable with `vim.g.pairs = false` (global) and `vim.b.pairs = false` (per-buffer)
  --      -- and/or with `vim.g.blink_pairs = false` and `vim.b.blink_pairs = false`
  --      disabled_filetypes = {},
  --      -- see the defaults:
  --      -- https://github.com/Saghen/blink.pairs/blob/main/lua/blink/pairs/config/mappings.lua#L14
  --      pairs = {},
  --    },
  --    highlights = {
  --      enabled = true,
  --      -- requires require('vim._extui').enable({}), otherwise has no effect
  --      cmdline = true,
  --      groups = {
  --        'BlinkPairsBlue',
  --        'BlinkPairsPurple',
  --        'BlinkPairsOrange',
  --      },
  --      unmatched_group = 'BlinkPairsUnmatched',

  --      -- highlights matching pairs under the cursor
  --      matchparen = {
  --        enabled = true,
  --        -- known issue where typing won't update matchparen highlight, disabled by default
  --        cmdline = false,
  --        -- also include pairs not on top of the cursor, but surrounding the cursor
  --        include_surrounding = false,
  --        group = 'BlinkPairsMatchParen',
  --        priority = 250,
  --      },
  --    },
  --    debug = false,
  --  }
  --}
}
