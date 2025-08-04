return {
  -- Override LazyVim's ESLint configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            workingDirectory = { mode = "auto" },
          },
          -- Enable ESLint formatting
          on_attach = function(client, bufnr)
            -- Enable formatting
            client.server_capabilities.documentFormattingProvider = true
            
            -- Auto-fix on save
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({
                  bufnr = bufnr,
                  filter = function(c)
                    return c.name == "eslint"
                  end,
                  async = false,
                })
              end,
              desc = "ESLint auto-fix on save",
            })
          end,
        },
      },
    },
  },
  
  -- Disable conform.nvim for JS/TS files to avoid conflicts
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = {},
        javascriptreact = {},
        typescript = {},
        typescriptreact = {},
        jsx = {},
        tsx = {},
        vue = {},
      },
    },
  },
}