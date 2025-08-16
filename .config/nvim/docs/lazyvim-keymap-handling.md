# LazyVim Keymap Handling Guide

## Overview
LazyVim has three types of keymaps that need to be handled differently when overriding:

1. **Core Keymaps** - Defined in LazyVim's internal files
2. **LSP Keymaps** - Applied when LSP attaches to a buffer
3. **Plugin Keymaps** - Defined in individual plugin specs

## 1. Core Keymaps

### Location
- Defined in LazyVim's core (internal keymaps.lua)
- Examples: `<leader>cf` (Format), `<leader>cd` (Line Diagnostics)

### How to Override
In `lua/config/keymaps.lua`:
```lua
-- Delete the original keymap
vim.keymap.del({ "n", "v" }, "<leader>cf")

-- Add your new keymap
vim.keymap.set({ "n", "v" }, "<leader>Cf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
```

## 2. LSP Keymaps

### Location
- Defined in LazyVim's LSP module
- Applied dynamically when LSP server attaches
- Examples: `<leader>ca` (Code Action), `<leader>cr` (Rename)

### How to Override
In `lua/plugins/lsp.lua`, use the `opts` function:
```lua
{
  "neovim/nvim-lspconfig",
  opts = function()
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    
    -- Disable default keymaps
    keys[#keys + 1] = { "<leader>ca", false }
    keys[#keys + 1] = { "<leader>cr", false }
    
    -- Add new keymaps
    keys[#keys + 1] = { "<leader>Ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } }
    keys[#keys + 1] = { "<leader>Cr", vim.lsp.buf.rename, desc = "Rename" }
  end,
}
```

## 3. Plugin Keymaps

### Location
- Defined in individual plugin specs
- Can be in LazyVim extras or user configs

### How to Override
In the plugin spec, use the `keys` property:
```lua
{
  "some/plugin",
  keys = {
    -- Disable a default keymap
    { "<leader>x", false },
    
    -- Add/override a keymap
    { "<leader>X", "<cmd>SomeCommand<cr>", desc = "New Command" },
  },
}
```

## Common Patterns

### Remapping an Entire Prefix
To move all `<leader>c` mappings to `<leader>C`:

1. **Core Keymaps** (in `lua/config/keymaps.lua`):
```lua
vim.keymap.del({ "n", "v" }, "<leader>cf")
vim.keymap.set({ "n", "v" }, "<leader>Cf", function() LazyVim.format({ force = true }) end, { desc = "Format" })
```

2. **LSP Keymaps** (in `lua/plugins/lsp.lua`):
```lua
opts = function()
  local keys = require("lazyvim.plugins.lsp.keymaps").get()
  
  -- Map of old to new keys
  local remaps = {
    ["<leader>ca"] = "<leader>Ca",
    ["<leader>cr"] = "<leader>Cr",
    -- ... etc
  }
  
  -- Process each keymap
  for i, key in ipairs(keys) do
    if remaps[key[1]] then
      -- Disable old key
      keys[#keys + 1] = { key[1], false }
      -- Add new key with same functionality
      keys[#keys + 1] = vim.tbl_extend("force", key, { [1] = remaps[key[1]] })
    end
  end
end
```

## Important Notes

1. **Mode Matching**: When disabling a keymap, you must match the exact mode(s) of the original
2. **Load Order**: `lua/config/keymaps.lua` loads before plugins, so core overrides go there
3. **LSP Keymaps**: Only applied when an LSP server is active in the buffer
4. **Precedence**: Later definitions override earlier ones

## Debugging Tips

- Use `:map <leader>c` to see all mappings starting with `<leader>c`
- Use `:verbose map <leader>ca` to see where a specific mapping was defined
- Check `:LspInfo` to ensure LSP is attached when testing LSP keymaps