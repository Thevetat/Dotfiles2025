local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- "
local userBin = os.getenv("HOME") .. "/.local/bin/"

-- 1. Window Management
hl.bind(mainMod .. " + W",       hl.dsp.window.close(), { description = "Close window" })
hl.bind(mainMod .. " + J",       hl.dsp.layout("togglesplit"), { description = "Toggle window split" })
hl.bind(mainMod .. " + T",       hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating or tiling" })
hl.bind("CONTROL + SHIFT + F",   hl.dsp.window.float({ action = "toggle" }), { description = "Toggle window floating or tiling" })
hl.bind(mainMod .. " + F",       hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Full screen" })
hl.bind(mainMod .. " + CONTROL + F", hl.dsp.exec_cmd(userBin .. "hyprland-window-tiled-fullscreen-toggle"), { description = "Tiled full screen" })
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Full width" })
hl.bind(mainMod .. " + O",       hl.dsp.exec_cmd(userBin .. "hyprland-window-pop"), { description = "Pop window out (float and pin)" })
hl.bind(mainMod .. " + E",       hl.dsp.exec_cmd(userBin .. "hyprland-equalize-columns"), { description = "Equalize columns" })
hl.bind("CONTROL + ALT + E",     hl.dsp.exec_cmd(userBin .. "hyprland-equalize-columns"), { description = "Equalize columns" })

-- 2. Window Focus
hl.bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "l" }), { description = "Focus window left" })
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }), { description = "Focus window right" })
hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "u" }), { description = "Focus window above" })
hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "d" }), { description = "Focus window below" })

hl.bind("ALT + H", hl.dsp.focus({ direction = "l" }), { description = "Focus window left" })
hl.bind("ALT + J", hl.dsp.focus({ direction = "d" }), { description = "Focus window below" })
hl.bind("ALT + K", hl.dsp.focus({ direction = "u" }), { description = "Focus window above" })
hl.bind("ALT + L", hl.dsp.focus({ direction = "r" }), { description = "Focus window right" })

local function cycle_window(next)
    return function()
        hl.dispatch(hl.dsp.window.cycle_next({ next = next }))
        hl.dispatch(hl.dsp.window.bring_to_top())
    end
end

hl.bind("ALT + TAB",         cycle_window(true), { description = "Focus next window" })
hl.bind("ALT + SHIFT + TAB", cycle_window(false), { description = "Focus previous window" })

-- 3. Moving Windows
hl.bind(mainMod .. " + SHIFT + LEFT",  hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })
hl.bind(mainMod .. " + SHIFT + UP",    hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind(mainMod .. " + SHIFT + DOWN",  hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })

hl.bind("ALT + SHIFT + H", hl.dsp.window.swap({ direction = "l" }), { description = "Swap window left" })
hl.bind("ALT + SHIFT + J", hl.dsp.window.swap({ direction = "d" }), { description = "Swap window down" })
hl.bind("ALT + SHIFT + K", hl.dsp.window.swap({ direction = "u" }), { description = "Swap window up" })
hl.bind("ALT + SHIFT + L", hl.dsp.window.swap({ direction = "r" }), { description = "Swap window right" })

hl.bind(mainMod .. " + SHIFT + ALT + LEFT",  hl.dsp.workspace.move({ monitor = "l" }), { description = "Move workspace to left monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + RIGHT", hl.dsp.workspace.move({ monitor = "r" }), { description = "Move workspace to right monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + UP",    hl.dsp.workspace.move({ monitor = "u" }), { description = "Move workspace to upper monitor" })
hl.bind(mainMod .. " + SHIFT + ALT + DOWN",  hl.dsp.workspace.move({ monitor = "d" }), { description = "Move workspace to lower monitor" })

-- 4. Window Groups
hl.bind(mainMod .. " + G", hl.dsp.group.toggle(), { description = "Toggle window grouping" })
hl.bind(mainMod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }), { description = "Move active window out of group" })

for _, direction in ipairs({
    { "LEFT", "l", "left" },
    { "RIGHT", "r", "right" },
    { "UP", "u", "top" },
    { "DOWN", "d", "bottom" },
}) do
    hl.bind(mainMod .. " + ALT + " .. direction[1], hl.dsp.window.move({ into_group = direction[2] }), {
        description = "Move window to group on " .. direction[3],
    })
end

hl.bind(mainMod .. " + ALT + TAB", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind(mainMod .. " + SHIFT + ALT + TAB", hl.dsp.group.prev(), { description = "Previous window in group" })
hl.bind(mainMod .. " + CONTROL + LEFT", hl.dsp.group.prev(), { description = "Move grouped window focus left" })
hl.bind(mainMod .. " + CONTROL + RIGHT", hl.dsp.group.next(), { description = "Move grouped window focus right" })
hl.bind(mainMod .. " + ALT + mouse_down", hl.dsp.group.next(), { description = "Next window in group" })
hl.bind(mainMod .. " + ALT + mouse_up", hl.dsp.group.prev(), { description = "Previous window in group" })

for index = 1, 5 do
    hl.bind(mainMod .. " + ALT + " .. index, hl.dsp.group.active({ index = index }), {
        description = "Switch to group window " .. index,
    })
end

-- 5. Window Resize
local resizeBinds = {
    { mainMod .. " + Minus",                    -100,    0, "Expand window left" },
    { mainMod .. " + Equal",                     100,    0, "Shrink window left" },
    { mainMod .. " + SHIFT + Minus",               0, -100, "Shrink window up" },
    { mainMod .. " + SHIFT + Equal",               0,  100, "Expand window down" },
    { mainMod .. " + ALT + Minus",               -25,    0, "Expand window left a little" },
    { mainMod .. " + ALT + Equal",                25,    0, "Shrink window left a little" },
    { mainMod .. " + SHIFT + ALT + Minus",          0,  -25, "Shrink window up a little" },
    { mainMod .. " + SHIFT + ALT + Equal",          0,   25, "Expand window down a little" },
    { mainMod .. " + CONTROL + Minus",           -300,    0, "Expand window left a lot" },
    { mainMod .. " + CONTROL + Equal",            300,    0, "Shrink window left a lot" },
    { mainMod .. " + CONTROL + SHIFT + Minus",      0, -300, "Shrink window up a lot" },
    { mainMod .. " + CONTROL + SHIFT + Equal",      0,  300, "Expand window down a lot" },
    { "CONTROL + ALT + H",                      -100,    0, "Resize window left" },
    { "CONTROL + ALT + J",                         0,  100, "Resize window down" },
    { "CONTROL + ALT + K",                         0, -100, "Resize window up" },
    { "CONTROL + ALT + L",                       100,    0, "Resize window right" },
}

for _, bind in ipairs(resizeBinds) do
    hl.bind(bind[1], hl.dsp.window.resize({ x = bind[2], y = bind[3], relative = true }), {
        repeating = true,
        description = bind[4],
    })
end

-- 6. Mouse and Monitors
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Move window with mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with mouse" })
hl.bind("CONTROL + ALT + TAB",         hl.dsp.focus({ monitor = "+1" }), { description = "Focus next monitor" })
hl.bind("CONTROL + ALT + SHIFT + TAB", hl.dsp.focus({ monitor = "-1" }), { description = "Focus previous monitor" })

-- 7. Accessibility
hl.bind(mainMod .. " + BACKSPACE", hl.dsp.exec_cmd(userBin .. "hyprland-window-transparency-toggle"), { description = "Toggle window transparency" })

-- 8. Applications
hl.bind(mainMod .. " + RETURN",               hl.dsp.exec_cmd(launchPrefix .. "ghostty -e /usr/bin/zsh -c 'fastfetch; exec /usr/bin/zsh'"), { description = "Terminal" })
hl.bind(mainMod .. " + SHIFT + F",            hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER), { description = "File manager" })
hl.bind(mainMod .. " + SHIFT + N",            hl.dsp.exec_cmd(launchPrefix .. EDITOR), { description = "Editor" })
hl.bind(mainMod .. " + SHIFT + RETURN",       hl.dsp.exec_cmd(userBin .. "launch-browser"), { description = "Spawn or focus browser" })
hl.bind(mainMod .. " + SHIFT + CONTROL + RETURN", hl.dsp.exec_cmd(userBin .. "launch-browser --new-window"), { description = "New browser window" })
hl.bind(mainMod .. " + SHIFT + ALT + RETURN", hl.dsp.exec_cmd(userBin .. "launch-browser --private"), { description = "Private browser window" })
hl.bind(mainMod .. " + CONTROL + T",          hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"), { description = "System monitor" })
hl.bind(mainMod .. " + S",                    hl.dsp.exec_cmd(userBin .. "hyprland-scratch-terminal " .. TERMINAL), { description = "Scratch terminal" })
hl.bind(mainMod .. " + SHIFT + V",            hl.dsp.exec_cmd(launchPrefix .. userBin .. "visualize"), { description = "Audio visualizer" })

-- 9. Noctalia Shell
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"), { description = "Application launcher" })
hl.bind(mainMod .. " + CONTROL + SPACE", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"), { description = "Background switcher" })
hl.bind(mainMod .. " + R",         hl.dsp.exec_cmd(noctCall .. "wallpaper-random"), { description = "Random wallpaper" })
hl.bind(mainMod .. " + SHIFT + CONTROL + SPACE", hl.dsp.exec_cmd(noctCall .. "settings-open appearance"), { description = "Theme switcher" })
hl.bind(mainMod .. " + K",         hl.dsp.exec_cmd(userBin .. "noctalia-keymap"), { description = "Keybindings" })
hl.bind(mainMod .. " + Z",         hl.dsp.exec_cmd(noctCall .. "settings-toggle"), { description = "Noctalia settings" })
hl.bind(mainMod .. " + ESCAPE",    hl.dsp.exec_cmd(noctCall .. "panel-toggle session"), { description = "Session menu" })
hl.bind(mainMod .. " + CONTROL + L", hl.dsp.exec_cmd(noctCall .. "session lock"), { description = "Lock screen" })

-- 10. Universal Clipboard
local terminalClasses = {
    ["alacritty"] = true,
    ["com.mitchellh.ghostty"] = true,
    ["foot"] = true,
    ["kitty"] = true,
    ["org.codeberg.dnkl.foot"] = true,
    ["wezterm"] = true,
}

local function active_window_is_terminal()
    local window = hl.get_active_window()
    if not window then
        return false
    end

    for _, tag in ipairs(window.tags or {}) do
        if tag:gsub("%*$", "") == "terminal" then
            return true
        end
    end

    return terminalClasses[(window.class or ""):lower()] == true
end

local function send_shortcut_once(mods, key)
    return function()
        hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))
        hl.timer(function()
            hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
        end, { timeout = 50, type = "oneshot" })
    end
end

local function universal_shortcut(defaultMods, defaultKey, terminalMods, terminalKey)
    return function()
        if active_window_is_terminal() then
            send_shortcut_once(terminalMods, terminalKey)()
        else
            send_shortcut_once(defaultMods, defaultKey)()
        end
    end
end

hl.bind(mainMod .. " + C", universal_shortcut("CTRL", "C", "CTRL", "Insert"), { description = "Universal copy" })
hl.bind(mainMod .. " + V", universal_shortcut("CTRL", "V", "SHIFT", "Insert"), { description = "Universal paste" })
hl.bind(mainMod .. " + X", send_shortcut_once("CTRL", "X"), { description = "Universal cut" })
hl.bind(mainMod .. " + CONTROL + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"), { description = "Clipboard history" })
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"), { description = "Notification history" })

-- 11. Hardware Controls
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true, description = "Toggle audio mute" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"), { locked = true, description = "Toggle microphone mute" })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true, description = "Play or pause media" })
hl.bind("XF86AudioPause",       hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true, description = "Play or pause media" })
hl.bind("XF86AudioNext",        hl.dsp.exec_cmd(noctCall .. "media next"), { locked = true, description = "Next media track" })
hl.bind("XF86AudioPrev",        hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true, description = "Previous media track" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd(noctCall .. "brightness-up"), { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true, description = "Brightness down" })

-- 12. Capture and Appearance
hl.bind("PRINT",                    hl.dsp.exec_cmd(noctCall .. "screenshot-region"), { description = "Capture screen region" })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(noctCall .. "screenshot-region"), { description = "Screenshot" })
hl.bind(mainMod .. " + PRINT",     hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"), { description = "Capture full screen" })
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("hyprpicker -a -n"), { description = "Color picker" })
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"), { description = "Wallpaper picker" })

-- 13. Workspaces
local showDesktopWorkspace = "show-desktop"

hl.bind(mainMod .. " + H", function()
    local workspace = hl.get_active_workspace()
    local target = workspace and workspace.name == showDesktopWorkspace
        and "previous"
        or "name:" .. showDesktopWorkspace

    hl.dispatch(hl.dsp.focus({ workspace = target }))
end, { description = "Toggle show desktop" })

for workspace = 1, 10 do
    local key = tostring(workspace % 10)
    local target = tostring(workspace)

    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = target }), {
        description = "Switch to workspace " .. workspace,
    })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = target, follow = true }), {
        description = "Move window to workspace " .. workspace,
    })
    hl.bind(mainMod .. " + SHIFT + ALT + " .. key, hl.dsp.window.move({ workspace = target, follow = false }), {
        description = "Move window silently to workspace " .. workspace,
    })
end

hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })
hl.bind(mainMod .. " + CONTROL + TAB", hl.dsp.focus({ workspace = "previous" }), { description = "Former workspace" })
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll workspace forward" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll workspace backward" })
