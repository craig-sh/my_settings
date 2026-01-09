return {
  {
    'kosayoda/nvim-lightbulb',
    opts = {
      autocmd = {
        enabled = true }
    }
  },
  {
    "neovim/nvim-lspconfig",
    -- event = { "BufReadPost", "BufNewFile" },
    -- cmd = { "LspInfo", "LspInstall", "LspUninstall" },
    dependencies = {
      {
        'j-hui/fidget.nvim',
        opts = {}
      },
      { 'saghen/blink.cmp' },
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        float = true
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)

      -- Global mappings.
      -- See `:help vim.diagnostic.*` for documentation on any of the below functions
      -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '<C-p>', vim.diagnostic.goto_prev)
      vim.keymap.set('n', '<C-n>', vim.diagnostic.goto_next)
      -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      --
      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local wk = require("which-key")
        wk.add({
          group = 'lsp',
          buffer = bufnr,
          mode = { 'n' },
          { 'gD', vim.lsp.buf.declaration,     desc = "Go to declaration" },
          { 'gd', vim.lsp.buf.definition,      desc = "Go to definition" },
          { 'gh', vim.lsp.buf.hover,           desc = "Hover" },
          { 'gi', vim.lsp.buf.implementation,  desc = "Go to implementation" }, -- Buffer local mappings.
          { 'K',  vim.lsp.buf.signature_help,  desc = "Help" },               -- See `:help vim.lsp.*` for documentation on any of the below functions
          -- {'<space>wa', vim.lsp.buf.add_workspace_folder,  desc = "Go to declaration"},
          -- {'<space>wr', vim.lsp.buf.remove_workspace_folder,  desc = "Go to declaration"},
          -- {'<space>wl', function()
          --  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          -- end, desc = "Go to declaration"},
          { 'gt', vim.lsp.buf.type_definition, desc = "Go do type definition" },
          { 'gR', vim.lsp.buf.rename,          desc = "Rename" },
          { 'gr', vim.lsp.buf.references,      desc = "Go to references" },
          {
            'gF',
            function()
              vim.lsp.buf.format { async = true }
            end,
            desc = "Format"
          },
          { '<leader>ca', mode = { 'n', 'v' }, vim.lsp.buf.code_action, desc = "Code Action" },
        })
        -- disable highlighting for strings so that our SQL injection takes precedence
        vim.api.nvim_set_hl(0, "@lsp.type.string.python", {})
      end


      local servers = { "hls", "ty", "rust_analyzer", "bashls", "ansiblels", "nixd", "ruff" }
      for _, lsp in ipairs(servers) do
        vim.lsp.enable(lsp)
        vim.lsp.config(lsp, {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    maxLineLength = 200,
                  },
                  flake8 = {
                    maxLineLength = 200,
                  },
                  ruff = {
                    enabled = true,
                    lineLength = 200,
                  }
                }
              },
            }
          }
        )
      end

      local runtime_path = vim.split(package.path, ';')
      table.insert(runtime_path, 'lua/?.lua')
      table.insert(runtime_path, 'lua/?/init.lua')
      vim.lsp.enable("lua_ls")
      vim.lsp.config("lua_ls", {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = { Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT)
                version = 'LuaJIT',
                -- Setup your lua path
                path = runtime_path,
              },
              diagnostics = {
                globals = { 'vim' },
              },
              workspace = { library = vim.api.nvim_get_runtime_file('', true) },
              -- Do not send telemetry data containing a randomized but unique identifier
              telemetry = { enable = false },
            },
          },
        }
      )
    end,
  },
}
