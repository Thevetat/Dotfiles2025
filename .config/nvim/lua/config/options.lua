-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local g = vim.g

-- Override LazyVim defaults
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.colorcolumn = "120"
vim.opt.hlsearch = false
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldenable = true
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/undodir"

-- Disable default format on save (we'll use selective formatting)
vim.g.autoformat = false

-- Enable ESLint auto format
vim.g.lazyvim_eslint_auto_format = true

g.transparency = true
vim.cmd([[set pumblend=0]])

-- Fix cursor shape in different modes
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

-- Enable true colors for proper color rendering
vim.opt.termguicolors = true
