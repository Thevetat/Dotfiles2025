return {
  -- Configure LSP servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
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