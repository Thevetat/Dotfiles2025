# Comprehensive Keybinds Reference

## Current Setup Analysis

### Neovim (LazyVim + Custom)

**Window Navigation (COMMENTED OUT - Not Active):**

- `<C-h>` - Go to left window (disabled)
- `<C-j>` - Go to lower window (disabled)
- `<C-k>` - Go to upper window (disabled)
- `<C-l>` - Go to right window (disabled)

**Window Resizing (COMMENTED OUT - Not Active):**

- `<C-Up>` - Increase window height (disabled)
- `<C-Down>` - Decrease window height (disabled)
- `<C-Left>` - Decrease window width (disabled)
- `<C-Right>` - Increase window width (disabled)

**Active Custom Keybinds:**

- `<leader>a` - Select all text
- `<F2>` - Rename symbol (LSP)
- `<leader>/` - Toggle comment (line in normal, selection in visual)
- `<C-u>/<C-d>` - Half page up/down (centered with zz)
- `j/k` - Smart movement (respects wrapped lines when no count)
- `<M-j>/<M-k>` - Move lines up/down (works in normal, insert, visual)
- `<A-Up>/<A-Down>` - Move lines up/down (alternative)
- `<D-s>` - Save file (Mac Cmd+S)
- `<leader>R` - Interactive command execution (prompts for input)

### Ghostty Terminal

**Split Management:**

- `Cmd+Shift+S` - New split right
- `Cmd+Shift+V` - New split down
- `Cmd+W` - Close current surface/pane

**Split Navigation (Arrow Keys):**

- `Cmd+Shift+Left` - Go to left split
- `Cmd+Shift+Down` - Go to bottom split
- `Cmd+Shift+Up` - Go to top split
- `Cmd+Shift+Right` - Go to right split

**Split Resizing:**

- `Cmd+Shift+Ctrl+H` - Resize split left by 10 units
- `Cmd+Shift+Ctrl+J` - Resize split down by 10 units
- `Cmd+Shift+Ctrl+K` - Resize split up by 10 units
- `Cmd+Shift+Ctrl+L` - Resize split right by 10 units

**Other:**

- `Shift+Enter` - Insert literal newline

### skhd (System Hotkeys)

**Space Navigation:**

- `Alt+1-5` - Focus spaces 1-5 on current display

**Window Navigation:**

- `Alt+H/J/K/L` - Focus window/display west/south/north/east

**Window Movement:**

- `Shift+Alt+H/J/K/L` - Warp/move window west/south/north/east
- `Shift+Alt+1-5` - Move window to space 1-5
- `Shift+Alt+P/N` - Move window to prev/next space (follows focus)
- `Shift+Alt+X` - Mirror space on X-axis
- `Shift+Alt+Y` - Mirror space on Y-axis

**Window Management:**

- `Shift+Alt+Space` - Toggle float + trigger sketchybar
- `Shift+Alt+F` - Toggle zoom-fullscreen
- `Cmd+Shift+F` - Toggle zoom-fullscreen (alternative)
- `Alt+F` - Toggle zoom-parent
- `Shift+Alt+S` - Toggle split orientation

**Window Resizing:**

- `Ctrl+Alt+H/J/K/L` - Resize window edges
- `Ctrl+Alt+E` - Balance/equalize window sizes
- `Ctrl+Alt+G` - Toggle padding and gaps
- `Ctrl+Alt+B` - Disable window borders
- `Shift+Ctrl+Alt+B` - Enable window borders

**Window Insertion:**

- `Shift+Ctrl+Alt+H/J/K/L` - Set insertion point west/south/north/east
- `Shift+Ctrl+Alt+S` - Set stack insertion point
- `Alt+S` - Insert east + new window (cmd-n)
- `Alt+V` - Insert south + new window (cmd-n)

**Application & System:**

- `Alt+T` - Open new Ghostty terminal window
- `Shift+Alt+T` - Run create spaces/organize desktop script
- `Shift+Alt+R` - Restart/reload sketchybar

### tmux (Terminal Multiplexer)

**Prefix Key: `Ctrl+Space`**

**Session Management:**

- `Ctrl+Space, D` - Detach from session
- `tmux new -s name` - Create new named session
- `tmux attach -t name` - Attach to named session
- `tmux list-sessions` - List all sessions
- `Ctrl+Space, S` - Save session (via plugin)

**Window Management:**

- `Ctrl+Space, n` - Create new window
- `Ctrl+Space, 1-9` - Switch to window by number
- `Ctrl+Space, W` - **Kill current window**
- `Ctrl+Space, R` - Rename current window
- `Ctrl+Space, P` - Pick window/pane to switch to

**Pane Management:**

- `Ctrl+Space, S` - Split pane vertically (side by side)
- `Ctrl+Space, V` - Split pane horizontally (top/bottom)
- `Ctrl+Space, %` - Split pane vertically (traditional)
- `Ctrl+Space, "` - Split pane horizontally (traditional)
- `Ctrl+Space, H/J/K/L` - Navigate between panes
- `Alt+Arrow Keys` - Navigate between panes (no prefix needed!)
- `Ctrl+Space, W` - **Kill/close current pane**
- `Ctrl+Space, X` - **Kill/close current pane** (alternative)
- `Ctrl+Space, Z` - Toggle pane zoom (fullscreen)

**Pane Resizing:**

- `Ctrl+Space, H/J/K/L` (Shift) - Resize pane by 5 units (hold to repeat)

**Copy Mode:**

- `Ctrl+Space, c` - Enter copy mode (easier than [)
- `Ctrl+Space, [` - Enter copy mode (traditional)
- `V` - Start selection (in copy mode)
- `Y` - Copy selection to clipboard (in copy mode)
- `F/Shift+F` - Search forward/backward (in copy mode)

**Other:**

- `Ctrl+Space, ?` - Show help/list all keybinds
- `Ctrl+Space, :` - Enter command mode
- `Ctrl+Space, Ctrl+L` - Clear screen and scrollback
- `Ctrl+Space, R` (uppercase) - Reload tmux config

### yabai (Window Manager)

**Layout Configuration:**

- BSP (Binary Space Partitioning) layout
- 50% default split ratio
- Second child window placement
- Auto-balance disabled
- Mouse doesn't follow focus

**Visual Settings:**

- Window borders: 4px width, 11px radius
- Active border: #44a1e3 (bright blue)
- Inactive border: #494d64 (dark gray)
- Insert feedback: #9dd274 (light green)
- Active windows: 100% opacity
- Inactive windows: 0% opacity (fully transparent)
- Animation duration: 300ms

**Gaps & Padding:**

- Window gap: 6px
- Top padding: 8px (+ 35px for SketchyBar)
- Bottom padding: 4px
- Left/Right padding: 4px

**Application Rules:**

- Spotify → Auto-moved to space 8
- Discord → Auto-moved to space 7
- Many system apps excluded from management

**Space Management:**

- Minimum 4 spaces per display
- 8 spaces system-wide minimum
- Dynamic space creation/destruction on display changes

## Recommended Optimized Workflow

### Problem Analysis

You're currently using `Alt+T` to create new Ghostty windows instead of leveraging splits. This creates window management overhead and doesn't utilize your existing split navigation keybinds.

### Recommended Changes

#### 1. Enhanced Ghostty Split Workflow

**Current Ghostty keybinds are good, but consider these additions:**

```
# Add to ~/.config/ghostty/config
keybind = super+d=new_split:right
keybind = super+shift+d=new_split:down
keybind = super+w=close_surface
```

#### 2. Unified Navigation Pattern

**Standardize on Vim-style HJKL across all tools:**

**Neovim - Uncomment and use:**

```lua
-- Enable these in ~/.config/nvim/lua/config/keymaps.lua
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
```

#### 3. Optimized Split Creation Workflow

**Instead of `Alt+T` for new windows, use:**

- `Cmd+D` - New vertical split in Ghostty (like tmux)
- `Cmd+Shift+D` - New horizontal split in Ghostty
- `Alt+S` - New horizontal split via yabai (system-wide)
- `Alt+V` - New vertical split via yabai (system-wide)

#### 4. Consistent Keybind Pattern

| Action               | Neovim       | Ghostty       | skhd/yabai |
| -------------------- | ------------ | ------------- | ---------- |
| **Navigate Left**    | `Ctrl+H`     | `Cmd+Shift+H` | `Alt+H`    |
| **Navigate Down**    | `Ctrl+J`     | `Cmd+Shift+J` | `Alt+J`    |
| **Navigate Up**      | `Ctrl+K`     | `Cmd+Shift+K` | `Alt+K`    |
| **Navigate Right**   | `Ctrl+L`     | `Cmd+Shift+L` | `Alt+L`    |
| **Split Vertical**   | `<leader>sv` | `Cmd+D`       | `Alt+S`    |
| **Split Horizontal** | `<leader>sh` | `Cmd+Shift+D` | `Alt+V`    |

### Implementation Priority

1. **High Priority**: Enable Neovim window navigation keybinds
2. **High Priority**: Add `Cmd+D` and `Cmd+Shift+D` to Ghostty for easier splitting
3. **Medium Priority**: Add `Cmd+W` to Ghostty for closing splits
4. **Low Priority**: Consider reducing reliance on `Alt+T` for new windows

### Workflow Recommendations

**For Development:**

1. Use `Cmd+D` to create vertical splits in Ghostty for side-by-side terminals
2. Use `Cmd+Shift+H/J/K/L` to navigate between Ghostty splits
3. Use `Ctrl+H/J/K/L` to navigate between Neovim windows/splits
4. Use `Alt+H/J/K/L` for system-wide window navigation when needed

**For Window Management:**

1. Leverage yabai's BSP layout for automatic window arrangement
2. Use `Alt+S/V` for system-wide splits when you need new application windows
3. Use `Shift+Alt+H/J/K/L` to move windows between positions
4. Use `Alt+1-5` for space navigation instead of creating many windows

## Fusion 360 Shortcuts

**Modeling:**

- `Ctrl+Shift+S` - New sketch
- `Ctrl+Shift+C` - New component
- `Ctrl+Shift+P` - Change parameters
