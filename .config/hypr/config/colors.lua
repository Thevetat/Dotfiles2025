-- Cachy color fallbacks

CACHYLGREEN = "rgba(82dcccd9)"
CACHYMGREEN = "rgba(00aa84d9)"
CACHYDGREEN = "rgba(007d6fd9)"
CACHYLBLUE  = "rgba(01ccffff)"
CACHYMBLUE  = "rgba(182545ff)"
CACHYDBLUE  = "rgba(111826ff)"
CACHYWHITE  = "rgba(ffffffff)"
CACHYGREY   = "rgba(ddddddff)"
CACHYGRAY   = "rgba(798bb2ff)"

local state_home = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
pcall(dofile, state_home .. "/noctalia/generated/hyprland-colors.lua")
