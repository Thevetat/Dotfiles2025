-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-reload files when changed externally
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
  desc = "Check if file changed when entering buffer",
})

-- Run EslintFixAll on save for JavaScript/TypeScript files
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.vue" },
  callback = function()
    -- Check if eslint LSP client is attached
    local clients = vim.lsp.get_active_clients({ name = "eslint", bufnr = 0 })
    if #clients > 0 then
      vim.cmd("EslintFixAll")
    end
  end,
  desc = "Run EslintFixAll on save",
})
