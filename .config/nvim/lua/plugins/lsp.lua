return {
  -- Configure conform for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Remove ESLint from conform - we'll use ESLint LSP instead
        -- javascript = { "prettier" },
        -- javascriptreact = { "prettier" },
        -- typescript = { "prettier" },
        -- typescriptreact = { "prettier" },
        -- jsx = { "prettier" },
        -- tsx = { "prettier" },
        -- vue = { "prettier" },
      },
      -- Configure formatters
      formatters = {
        eslint_d = {
          -- Remove the deprecated options
          args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
          stdin = true,
          cwd = require("conform.util").root_file({
            ".eslintrc",
            ".eslintrc.js",
            ".eslintrc.json",
            ".eslintrc.yml",
            ".eslintrc.yaml",
            "eslint.config.js",
            "eslint.config.mjs",
          }),
        },
        eslint = {
          command = "eslint",
          args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
          stdin = true,
        },
      },
    },
  },
  
  -- Make sure ESLint LSP is configured properly
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          settings = {
            -- Use your project's ESLint config
            workingDirectory = { mode = "auto" },
            -- Enable ESLint formatting since we're not using conform.nvim for ESLint
            format = true,
          },
          -- Enable ESLint LSP formatting capabilities
          on_attach = function(client, bufnr)
            -- Enable formatting from ESLint LSP
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
          end,
        },
        tsserver = {
          init_options = {
            preferences = {
              -- Limit completions for better performance
              includeCompletionsWithSnippetText = true,
              includeCompletionsForImportStatements = true,
              includeCompletionsWithClassMemberSnippets = true,
            },
            -- Increase memory limit for large projects
            maxTsServerMemory = 8192,
          },
        },
      },
    },
  },
}