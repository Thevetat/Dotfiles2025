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

-- Word wrap settings for better readability
vim.opt.wrap = true         -- Enable line wrapping at window edge
vim.opt.linebreak = true    -- Wrap at word boundaries, not mid-word
vim.opt.breakindent = true  -- Preserve indentation in wrapped lines
vim.opt.showbreak = "↪ "    -- Visual indicator for wrapped lines

-- Auto-reload files and disable swap/backup files
vim.opt.autoread = true     -- Automatically reload files changed outside Neovim
vim.opt.swapfile = false    -- Disable swap files completely (no more .swp conflicts)
vim.opt.backup = false      -- Disable backup files
vim.opt.writebackup = false -- Disable write backup

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

vim.g.snacks_scroll = false
vim.opt.mousescroll = "ver:1,hor:6"

-- Smart clipboard configuration
-- Always use system clipboard integration
vim.opt.clipboard = "unnamedplus"

-- For SSH sessions, ensure OSC 52 works if available
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  -- Let Neovim handle OSC 52 automatically with clipboard=unnamedplus
  -- This works better with tmux's set-clipboard feature
  vim.g.clipboard = nil  -- Use Neovim's built-in clipboard handling
end
