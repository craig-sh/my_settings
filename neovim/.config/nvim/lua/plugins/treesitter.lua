return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    branch = "main",
    lazy = false,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        branch = "main",
        lazy=false,
        config = function()
          require("nvim-treesitter-textobjects").setup {
            select = {
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
              -- You can choose the select mode (default is charwise 'v')
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * method: eg 'v' or 'o'
              -- and should return the mode ('v', 'V', or '<c-v>') or a table
              -- mapping query_strings to modes.
              selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
              },
              -- If you set this to `true` (default is `false`) then any textobject is
              -- extended to include preceding or succeeding whitespace. Succeeding
              -- whitespace has priority in order to act similarly to eg the built-in
              -- `ap`.
              --
              -- Can also be a function which gets passed a table with the keys
              -- * query_string: eg '@function.inner'
              -- * selection_mode: eg 'v'
              -- and should return true of false
              include_surrounding_whitespace = false,
            },
          }
          vim.keymap.set({ "x", "o" }, "af", function()
            require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
          end)
          vim.keymap.set({ "x", "o" }, "if", function()
            require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
          end)
          vim.keymap.set({ "x", "o" }, "ac", function()
            require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
          end)
          vim.keymap.set({ "x", "o" }, "ic", function()
            require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
          end)
          -- You can also use captures from other query groups like `locals.scm`
          vim.keymap.set({ "x", "o" }, "as", function()
            require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
          end)
        end
      }
    },
    config = function()
      local ts = require('nvim-treesitter')
      vim.g.ts_install = {
        'bash',
        'comment',
        'diff',
        'git_config',
        'git_rebase',
        'gitcommit',
        'gitignore',
        'haskell',
        'html',
        'javascript',
        'json',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'nix',
        'python',
        'query',
        'sql',
        'ssh_config',
        'toml',
        'vim',
        'vimdoc',
        'vue',
        'xml',
      }
      local ts_install = vim.g.ts_install or {}
      local ts_filetypes = vim
        .iter(ts_install)
        :map(function(lang)
          return vim.treesitter.language.get_filetypes(lang)
        end)
        :flatten()
        :totable()

      -- Install core parsers at startup
      ts.install(ts_install)

      local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

      local ignore_filetypes = {
        'checkhealth',
        'lazy',
        'mason',
        'snacks_dashboard',
        'snacks_notif',
        'snacks_win',
      }

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Setup treesitter for a buffer",
        -- NOTE: We explicitly define filetypes
        pattern = ts_filetypes,
        group = vim.api.nvim_create_augroup("ts_setup", { clear = true }),
        callback = function(e)
          vim.treesitter.start(e.buf)
          vim.wo.foldmethod = "expr"
          -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
 {
    {
      "MeanderingProgrammer/treesitter-modules.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      opts = {
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<C-s>",
            node_decremental = "<C-r>",
          },
        },
      },
    },
  },
}
