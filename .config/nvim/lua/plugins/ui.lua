return {
  -- Configure tokyonight theme
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- Highlight colors
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      render = "virtual",
      virtual_symbol = "■",
      virtual_symbol_position = "inline",
      virtual_symbol_prefix = " ",
      virtual_symbol_suffix = "",
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
      enable_var_usage = true,
      enable_named_colors = true,
      enable_tailwind = false,
      custom_colors = {},
      exclude_filetypes = {},
      exclude_buftypes = {},
    },
  },
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            "pnpm-lock.yaml",
          },
          always_show = {
            ".gitignore",
            ".env",
          },
        },
        follow_current_file = {
          enabled = true,
        },
      },
    },
  },
}
