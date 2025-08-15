return {
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>s", group = false },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    init = function()
      -- Override search keymaps with save
      vim.api.nvim_create_autocmd("VeryLazy", {
        callback = function()
          -- Remove the search keymap group if it exists
          pcall(vim.keymap.del, "n", "<leader>s")
          
          -- Add save keybinding
          vim.keymap.set({ "n", "i", "v" }, "<leader>s", "<cmd>w<cr><esc>", { desc = "Save file", silent = true })
        end,
      })
    end,
  },
}