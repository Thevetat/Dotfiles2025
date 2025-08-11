-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Essential custom keymaps
vim.keymap.set("n", "<leader>a", "<esc>ggVG<CR>", { desc = "Select all" })
vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })

-- Comment toggling
vim.keymap.set("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })
vim.keymap.set("v", "<leader>/", "gc", { desc = "Toggle comment", remap = true })

-- Center view after jumping
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Smart j/k movement (respects wrapped lines)
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move lines with Alt+j/k
vim.keymap.set("n", "<M-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<M-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<M-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<M-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Move lines with Alt+Arrow keys
vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Window navigation (optional - uncomment if you want them)
vim.keymap.set("n", "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "Go to right window" })

-- Window resizing (optional - uncomment if you want them)
-- vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Save with Cmd+S on Mac
vim.keymap.set({ "n", "i", "v" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Swap leader e and E keymaps
vim.keymap.set("n", "<leader>e", function()
  Snacks.picker.explorer({ cwd = vim.fn.getcwd() })
end, { desc = "Explorer (cwd)" })

-- Window splits (override LazyVim defaults to match tmux convention)
-- s = side-by-side (vertical split), v = stacked (horizontal split)
vim.keymap.set("n", "<leader>ws", "<C-w>v", { desc = "Split window right" })
vim.keymap.set("n", "<leader>wv", "<C-w>s", { desc = "Split window below" })

-- Quick command execution in current file's directory
vim.keymap.set("n", "<leader>R", function()
  local cmd = vim.fn.input("Command: ")
  if cmd ~= "" then
    vim.cmd("!" .. cmd)
  end
end, { desc = "Run command" })

-- Comment box
vim.keymap.set({ "n", "v" }, "<leader>cb", "<Cmd>CBllbox1<CR>", { desc = "Comment Box" })
