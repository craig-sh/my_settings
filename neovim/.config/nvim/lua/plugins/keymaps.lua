return {
  --{ 'ojroques/nvim-osc52', opts = { tmux_passthrough = true } },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
    opts = {
      spec = {
        {
          noremap = true,
          {
            "<leader>ev",
            function()
              Snacks.picker.files({
                dirs = {"$HOME/my_settings/neovim/.config/nvim/lua/plugins"}
              })
            end,
            desc = "Edit plugin files"
          },
          {
            "<leader>es",
            function()
              Snacks.picker.files({
                dirs = {"/home/craig/my_settings/neovim/.config/nvim/mysnips/"}
              })
            end,
            desc = "Edit snippet files"
          },
          {
            "<leader>en",
            function()
              Snacks.picker.files({
                dirs = {"/home/craig/my_settings/nix-flakes/"}
              })
            end,
            desc = "Edit nix files"
          },
          { '<F3>',               '::NvimTreeFindFileToggle<CR>',                 desc = 'Tree finder' },
          { '<leader>cf',         [[:let @+=expand("%")<CR>]],                    desc = 'Copy relative path of file', },
          { '<leader>pwd',        ':! pwd<CR>',                                   desc = 'Print the pwd', },
          { '<leader>ss',         ':syntax sync fromstart<CR>',                   desc = 'Resync syntax', },
          { '<leader><leader>dt', [[<C-R>=strftime('%Y%m%d')<CR>]],               desc = 'Insert current date',            mode = 'i' },
          { '<leader><leader>dd', ':! meld % &<CR>',                              desc = 'Git current file diff', },
          { '<leader><leader>fd', ':! meld $(pwd) &<CR>',                         desc = 'Git working tree diff', },
          { '<leader><leader>fm', ':! git dirdiff master &<CR>',                  desc = 'Git diff against master', },
          { '<leader><leader>pl', ':! pylint %<CR>',                              desc = 'Pylint', },
          { '<leader><leader>mp', '::! mypy % --follow-imports=silent<CR> %<CR>', desc = 'mp', },
          { '<leader><leader>pc', ':!pre-commit run --file %<CR>',                desc = 'Run pre-commit on current file', },
          { 'jj',                 '<Esc>',                                        desc = 'Change to normal mode',          mode = 'i',   silent = true },
          { '<F5>',               [[%s/\s\+$//e]],                                desc = 'Remove trailing white space',    expr = true },
          { '<A-k>',              ':wincmd k<CR>',                                desc = 'Window: Move up',                silent = true },
          { '<A-j>',              ':wincmd j<CR>',                                desc = 'Window: Move down',              silent = true },
          { '<A-h>',              ':wincmd h<CR>',                                desc = 'Window: Move left',              silent = true },
          { '<A-l>',              ':wincmd l<CR>',                                desc = 'Window: Move right',             silent = true },
          { '<Esc>',              [[<C-\><C-n>]],                                 desc = 'Term: normal mode',              mode = 't' },
          { '<M-[>',              '<Esc>',                                        desc = 'Term: send esc',                 mode = 't' },
          { '<C-v><Esc>',         '<Esc>',                                        desc = 'Term: send esc',                 mode = 't' },
          { '<A-h>',              [[<C-\><C-n><C-w>h]],                           desc = 'Term: (window) move left',       mode = 't' },
          { '<A-j>',              [[<C-\><C-n><C-w>j]],                           desc = 'Term: (window) move down',       mode = 't' },
          { '<A-k>',              [[<C-\><C-n><C-w>k]],                           desc = 'Term: (window) move up',         mode = 't' },
          { '<A-l>',              [[<C-\><C-n><C-w>l]],                           desc = 'Term: (window) move right',      mode = 't' },
          { '<leader>y',          require('vim.ui.clipboard.osc52').copy,         expr = true },
          { '<leader>yy',         '<leader>y_',                                   remap = true },
          { '<leader>y',          require('vim.ui.clipboard.osc52').copy,         mode = 'v' },
        },
      }
    }
  },
}
