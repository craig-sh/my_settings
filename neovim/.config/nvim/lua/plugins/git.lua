return {
  { 'rhysd/git-messenger.vim' },
  { 'sindrets/diffview.nvim' },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', '<C-j>', function()
          if vim.wo.diff then
            vim.cmd.normal({ '<C-j>', bang = true })
          else
            gitsigns.nav_hunk('next')
          end
        end)

        map('n', '<C-k>', function()
          if vim.wo.diff then
            vim.cmd.normal({ '<C-k>', bang = true })
          else
            gitsigns.nav_hunk('prev')
          end
        end)

        -- Actions
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = "Stage hunk" })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = "Reset hunk" })

        map('v', '<leader>hs', function()
          gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
        end, { desc = "Stage visual hunk" })

        map('v', '<leader>hr', function()
          gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }, { desc = "Reset Visual Hunk" })
        end)

        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = "Stage buffer" })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = "Reset buffer" })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview hunk" })
        map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = "Preview hunk inline" })

        map('n', '<leader>hb', function()
          gitsigns.blame_line({ full = true })
        end, { desc = "Blame link" })

        map('n', '<leader>hd', gitsigns.diffthis, { desc = "Diff this" })

        map('n', '<leader>hD', function()
          gitsigns.diffthis('~')
        end, { desc = "Diff against head?" })

        map('n', '<leader>hQ', function() gitsigns.setqflist('all') end, { desc = "Set qflist all" })
        map('n', '<leader>hq', gitsigns.setqflist, {desc = "Set qflist"})

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {desc = "Toggle blame link"})
        map('n', '<leader>td', gitsigns.toggle_deleted, {desc = "Toggle deleted"})
        map('n', '<leader>tw', gitsigns.toggle_word_diff, {desc = "Toggle word diff"})

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', {desc = "Select hunk"})
      end,
      current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 2000,
      },
    }
  }
}
