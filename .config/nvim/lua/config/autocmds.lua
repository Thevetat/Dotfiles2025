-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-reload files when changed externally (enhanced detection)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "checktime",
  desc = "Check if file changed when entering buffer or cursor is idle",
})

-- Notify when file is reloaded from disk
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File reloaded from disk", vim.log.levels.INFO)
  end,
  desc = "Notify when file is reloaded",
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

-- Enable autoformat for specific file types (excluding ESLint-handled files)
local format_on_save_filetypes = {
  lua = true,
  python = true,
  rust = true,
  go = true,
  sh = true,
  bash = true,
  zsh = true,
  yaml = true,
  toml = true,
  markdown = true,
  -- JSON can be formatted by prettier/eslint but we'll enable it here too
  json = true,
  jsonc = true,
  -- CSS/SCSS/etc
  css = true,
  scss = true,
  sass = true,
  less = true,
  -- HTML
  html = true,
  -- Config files
  vim = true,
  -- Explicitly NOT including JS/TS files as they're handled by ESLint
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    -- Enable autoformat for specific file types
    if format_on_save_filetypes[filetype] then
      vim.b[args.buf].autoformat = true
    end
  end,
  desc = "Enable autoformat for non-ESLint file types",
})
