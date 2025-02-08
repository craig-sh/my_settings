return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup({
      org_agenda_files = { '/home/craig/workspace/grepo/scratch/org/*' },
      org_default_notes_file = '/home/craig/workspace/grepo/scratch/org/refile.org',
      org_startup_indented = true,
      mappings = {
        org = {
          org_next_visible_heading = 'g}}',
          org_previous_visible_heading = 'g{{'
        }
      },
      org_custom_exports = {
        f = {
          label = 'Export to Redmine format',
          action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r')..'.textile'
            local command = {'pandoc', current_file, '-o', target}
            local on_success = function(output)
              print('Success!')
              vim.api.nvim_echo({{ table.concat(output, '\n') }}, true, {})
            end
            local on_error = function(err)
              print('Error!')
              vim.api.nvim_echo({{ table.concat(err, '\n'), 'ErrorMsg' }}, true, {})
            end
            return exporter(command , target, on_success, on_error)
          end
        }
      }
    })
  end,
}
