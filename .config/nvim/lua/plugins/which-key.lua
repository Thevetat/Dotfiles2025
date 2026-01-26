return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>s", "<cmd>w<cr>", desc = "Save file", mode = { "n", "v" } },
        { "<leader>C", group = "code" },
        { "<leader>c", group = "claude" },
      },
    },
  },
}
