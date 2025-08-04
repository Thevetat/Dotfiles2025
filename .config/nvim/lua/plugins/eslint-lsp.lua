-- Use ESLint LSP for formatting instead of eslint_d to avoid deprecated options error
return {
  -- Disable eslint_d in nvim-lint to avoid the deprecated options error
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- Remove eslint_d from linters
      opts.linters_by_ft = opts.linters_by_ft or {}
      
      -- Clear eslint_d from JavaScript/TypeScript file types
      local eslint_filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "jsx",
        "tsx",
      }
      
      for _, ft in ipairs(eslint_filetypes) do
        -- Remove eslint_d from the linters for these file types
        if opts.linters_by_ft[ft] then
          opts.linters_by_ft[ft] = vim.tbl_filter(function(linter)
            return linter ~= "eslint_d" and linter ~= "eslint"
          end, opts.linters_by_ft[ft])
        end
      end
      
      return opts
    end,
  },
  
  -- Configure ESLint LSP to handle formatting
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- Enable auto fix on save
            codeActionOnSave = {
              enable = true,
              mode = "all"
            },
            -- Use your project's ESLint config
            workingDirectory = { mode = "auto" },
          },
        },
      },
      setup = {
        eslint = function()
          -- Setup autocommand to format on save using ESLint LSP
          vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue" },
            callback = function(args)
              -- Use ESLint LSP to fix the file
              vim.lsp.buf.format({
                async = false,
                filter = function(client)
                  return client.name == "eslint"
                end,
              })
            end,
          })
        end,
      },
    },
  },
}