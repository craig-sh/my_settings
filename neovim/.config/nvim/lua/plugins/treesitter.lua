return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      lazy=true,
    }
  },
  config = function()
    require("nvim-treesitter.install").compilers = { require("tools").gcc }
    require 'nvim-treesitter.configs'.setup {
      highlight = {
        enable = true,
        -- additional_vim_regex_highlighting = { 'org' }, -- Required since TS highlighter doesn't support all syntax features (conceal)
      },
      -- don't add org here, it will manage its own treesitter stuff
      ensure_installed = { 'python', 'bash', 'vim', 'lua', 'javascript', 'sql', 'haskell', 'ssh_config', 'nix' },
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
  end,
}
