return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      local wk = require("which-key")
      wk.add({
        { "<leader>s", "<cmd>w<cr>", desc = "Save file", mode = { "n", "i", "v" } },
      })
    end,
  },
}
