return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters = opts.linters or {}
      opts.linters["markdownlint-cli2"] = opts.linters["markdownlint-cli2"] or {}
      opts.linters["markdownlint-cli2"].args = { "--disable", "MD012", "MD013", "-" }
    end,
  },
}
