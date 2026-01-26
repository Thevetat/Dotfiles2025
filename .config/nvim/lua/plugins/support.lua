return {
  {
    "christoomey/vim-tmux-navigator",
  },
  {
    "LudoPinelli/comment-box.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>Cb", "<Cmd>CBllbox1<CR>", desc = "Comment Box", mode = { "n", "v" } },
    },
    opts = {
      box_width = 70, -- width of the boxex
      borders = { -- symbols used to draw a box
        top = "─",
        bottom = "─",
        left = "│",
        right = "│",
        top_left = "╭",
        top_right = "╮",
        bottom_left = "╰",
        bottom_right = "╯",
      },
      line_width = 70, -- width of the lines
      line = { -- symbols used to draw a line
        line = "─",
        line_start = "─",
        line_end = "─",
      },
      outer_blank_lines = false, -- insert a blank line above and below the box
      inner_blank_lines = false, -- insert a blank line above and below the text
      line_blank_line_above = false, -- insert a blank line above the line
      line_blank_line_below = false, -- insert a blank line below the line
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    keys = {
      -- Disable default keymaps
      { "<leader>cs", false },
      { "<leader>cS", false },
      -- Add new keymaps
      { "<leader>Cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>CS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
    },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
        -- diagnostics = {
        --   auto_open = true,
        --   auto_close = true,
        -- },
      },
    },
  },
  {
    "jfryy/keytrail.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("keytrail").setup({
        delimiter = ".",
        hover_delay = 100,
        key_mapping = "jq", -- <leader>jq triggers picker by default
        filetypes = { json = true, yaml = true },
      })
    end,
  },
}
