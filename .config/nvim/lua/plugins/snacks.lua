return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {},
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = false,
            exclude = { "**/pnpm-lock.yaml" },
          },
        },
      },
    },
  },
}