local state_home = vim.env.XDG_STATE_HOME or vim.fn.expand("~/.local/state")
local generated_theme = state_home .. "/noctalia/generated/nvim-base16.lua"

local function apply_theme()
  local ok, colors = pcall(dofile, generated_theme)
  if not ok or type(colors) ~= "table" then
    vim.g.noctalia_theme_source = "fallback"
    vim.cmd.colorscheme("tokyonight-storm")
    return
  end

  require("base16-colorscheme").setup(colors)
  vim.g.colors_name = "noctalia-base16"
  vim.g.noctalia_theme_source = generated_theme
  vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "noctalia-base16" })
end

local signal

return {
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      signal = assert(vim.uv.new_signal())
      signal:start("sigusr1", vim.schedule_wrap(function()
        apply_theme()
        vim.cmd("redraw!")
      end))

      vim.api.nvim_create_autocmd("VimLeavePre", {
        once = true,
        callback = function()
          signal:stop()
          signal:close()
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = apply_theme,
    },
  },
}
