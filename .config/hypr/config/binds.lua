local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- " -- if you are not using UWSM, make this empty (e.g. "")

---------------------------
---- WINDOW MANAGEMENT ----
---------------------------

-- 1. Window Management
hl.bind(mainMod .. " + Escape",      hl.dsp.exec_cmd("hyprctl kill"), { description = "Select a window to kill" })
hl.bind(mainMod .. " + Q",           hl.dsp.window.close(), { description = "Close active window" })
hl.bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating window" })
hl.bind(mainMod .. " + D",           hl.dsp.window.fullscreen({ mode = 1 }), { description = "Toggle maximize" })
hl.bind(mainMod .. " + F",           hl.dsp.window.fullscreen(), { description = "Toggle fullscreen" })
hl.bind(mainMod .. " + J",           hl.dsp.layout("togglesplit"), { description = "Toggle split direction" })

-- 2. Window Focus
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }), { description = "Focus window left" })
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus window right" })
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }), { description = "Focus window up" })
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }), { description = "Focus window down" })
hl.bind("ALT + Tab",           hl.dsp.window.cycle_next(), { description = "Cycle windows" })
hl.bind(mainMod .. " + Tab",   hl.dsp.exec_cmd(noctCall .. "window-switcher"), { description = "Window switcher" })

-- 3. Moving Windows
hl.bind(mainMod .. " + SHIFT + Up",                   hl.dsp.window.move({ direction = "u" }), { description = "Move window up" })
hl.bind(mainMod .. " + SHIFT + Right",                hl.dsp.window.move({ direction = "r" }), { description = "Move window right" })
hl.bind(mainMod .. " + SHIFT + Left",                 hl.dsp.window.move({ direction = "l" }), { description = "Move window left" })
hl.bind(mainMod .. " + SHIFT + Down",                 hl.dsp.window.move({ direction = "d" }), { description = "Move window down" })
hl.bind(mainMod .. " + SHIFT + 1",                    hl.dsp.window.move({ monitor = MONITOR1 }), { description = "Move window to monitor 1" })
hl.bind(mainMod .. " + SHIFT + 2",                    hl.dsp.window.move({ monitor = MONITOR2 }), { description = "Move window to monitor 2" })
hl.bind(mainMod .. " + SHIFT + 3",                    hl.dsp.window.move({ monitor = MONITOR3 }), { description = "Move window to monitor 3" })
hl.bind(mainMod .. " + SHIFT + mouse_up",             hl.dsp.window.move({ monitor = "-1" }), { description = "Move window to previous monitor" })
hl.bind(mainMod .. " + SHIFT + mouse_down",           hl.dsp.window.move({ monitor = "+1" }), { description = "Move window to next monitor" })
hl.bind(mainMod .. " + CONTROL + SHIFT + Right",      hl.dsp.window.move({ workspace = "m+1" }), { description = "Move window to next workspace" })
hl.bind(mainMod .. " + CONTROL + SHIFT + Left",       hl.dsp.window.move({ workspace = "m-1" }), { description = "Move window to previous workspace" })
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_up",   hl.dsp.window.move({ workspace = "m-1" }), { description = "Move window to previous workspace" })
hl.bind(mainMod .. " + CONTROL + SHIFT + mouse_down", hl.dsp.window.move({ workspace = "m+1" }), { description = "Move window to next workspace" })
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + CONTROL + " .. key, hl.dsp.window.move({ workspace = "m~" .. i }), { description = "Move window to workspace " .. i })
end

-- 4. Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { description = "Move window with mouse" })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { description = "Resize window with mouse" })

-- 5. Accessibility
local function zoomfunction(value)
    local zoomvalue = hl.get_config("cursor:zoom_factor")
    if (zoomvalue + value) > 3.0 then
        hl.config({ cursor = { zoom_factor = 3.0 } })
    elseif (zoomvalue + value) < 1.0 then
        hl.config({ cursor = { zoom_factor = 1.0 } })
    else
        hl.config({ cursor = { zoom_factor = zoomvalue + value } })
    end
end
hl.bind(mainMod .. " + Minus", function() zoomfunction(-0.3) end, { repeating = true, description = "Zoom out" })
hl.bind(mainMod .. " + Plus", function() zoomfunction(0.3) end, { repeating = true, description = "Zoom in" })

-- Zoom with keypad
hl.bind(mainMod .. " + code:82", function() zoomfunction(-0.3) end, { repeating = true, description = "Zoom out" })
hl.bind(mainMod .. " + code:86", function() zoomfunction(0.3) end, { repeating = true, description = "Zoom in" })


------------------
---- LAUNCHER ----
------------------

-- 6. Applications
hl.bind(mainMod .. " + Return",     hl.dsp.exec_cmd(launchPrefix .. TERMINAL), { description = "Terminal" })
hl.bind(mainMod .. " + E",          hl.dsp.exec_cmd(launchPrefix .. FILE_MANAGER), { description = "File manager" })
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(launchPrefix .. EDITOR), { description = "Editor" })
hl.bind(mainMod .. " + C",          hl.dsp.exec_cmd(launchPrefix .. CALCULATOR), { description = "Calculator" })
hl.bind("XF86Calculator",           hl.dsp.exec_cmd(launchPrefix .. CALCULATOR), { description = "Calculator" })
hl.bind(mainMod .. " + W",          hl.dsp.exec_cmd(launchPrefix .. BROWSER), { description = "Browser" })
hl.bind("CONTROL + SHIFT + Escape", hl.dsp.exec_cmd(launchPrefix .. TERMINAL .. " -e btop"), { description = "System monitor" })
hl.bind(mainMod .. " + Z",          hl.dsp.exec_cmd(noctCall .. "settings-toggle"), { description = "Noctalia settings" })
hl.bind(mainMod .. " + X",          hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center"), { description = "Control center" })
hl.bind(mainMod .. " + Space",      hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher"), { description = "Application launcher" })
hl.bind(mainMod .. " + period",     hl.dsp.exec_cmd(noctCall .. "panel-toggle launcher /emo"), { description = "Emoji picker" })
hl.bind(mainMod .. " + K",          hl.dsp.exec_cmd(noctCall .. "panel-toggle kenn/keybind-cheatsheet:cheatsheet"), { description = "Keybindings" })
hl.bind(mainMod .. " + L",          hl.dsp.exec_cmd(noctCall .. "session lock"), { description = "Lock screen" })
hl.bind(mainMod .. " + ALT + C",    hl.dsp.exec_cmd(noctCall .. "panel-toggle session"), { description = "Session menu" })

---------------------------
---- HARDWARE CONTROLS ----
---------------------------

-- 7. Audio and Media
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(noctCall .. "volume-up"), { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(noctCall .. "volume-down"), { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd(noctCall .. "volume-mute"), { locked = true, description = "Toggle audio mute" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd(noctCall .. "mic-mute"), { locked = true, description = "Toggle microphone mute" })

hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true, description = "Play or pause media" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(noctCall .. "media toggle"), { locked = true, description = "Play or pause media" })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(noctCall .. "media next"), { locked = true, description = "Next media track" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(noctCall .. "media previous"), { locked = true, description = "Previous media track" })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(noctCall .. "brightness-up"), { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(noctCall .. "brightness-down"), { locked = true, repeating = true, description = "Brightness down" })

-------------------
---- UTILITIES ----
-------------------

-- 8. Screen Capture
hl.bind(mainMod .. " + P",     hl.dsp.exec_cmd("hyprpicker -a -n"), { description = "Color picker" })
hl.bind("Print",               hl.dsp.exec_cmd(noctCall .. "screenshot-region"), { description = "Capture screen region" })
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(noctCall .. "screenshot-fullscreen"), { description = "Capture full screen" })

-- 9. Appearance
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(noctCall .. "panel-toggle wallpaper"), { description = "Wallpaper picker" })

-- 10. Utilities
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(noctCall .. "panel-toggle clipboard"), { description = "Clipboard history" })
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(noctCall .. "panel-toggle control-center notifications"), { description = "Notifications" })

-------------------------------
---- WORKSPACES & MONITORS ----
-------------------------------

-- 11. Monitors
hl.bind(mainMod .. " + 1", hl.dsp.focus({ monitor = MONITOR1 }), { description = "Focus monitor 1" })
hl.bind(mainMod .. " + 2", hl.dsp.focus({ monitor = MONITOR2 }), { description = "Focus monitor 2" })
hl.bind(mainMod .. " + 3", hl.dsp.focus({ monitor = MONITOR3 }), { description = "Focus monitor 3" })

-- 12. Workspaces
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.focus({ workspace = i }), { description = "Focus workspace " .. i })
end
for i = 1, NUM_WPM do
    local key = i % 10
    hl.bind(mainMod .. " + CONTROL + " .. key, hl.dsp.focus({ workspace = "m~" .. i }), { description = "Focus workspace on current monitor " .. i })
end

hl.bind(mainMod .. " + CONTROL + Right",       hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace" })
hl.bind(mainMod .. " + CONTROL + Left",        hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace" })
hl.bind(mainMod .. " + CONTROL + Down",        hl.dsp.focus({ workspace = "emptym" }), { description = "Focus next empty workspace" })

hl.bind(mainMod .. " + mouse_down",           hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace" })
hl.bind(mainMod .. " + mouse_up",             hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace" })
hl.bind(mainMod .. " + CONTROL + mouse_up",   hl.dsp.focus({ workspace = "m-1" }), { description = "Focus previous workspace" })
hl.bind(mainMod .. " + CONTROL + mouse_down", hl.dsp.focus({ workspace = "m+1" }), { description = "Focus next workspace" })

-- 13. Scratchpad
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special" }), { description = "Move window to scratchpad" })
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special(), { description = "Toggle scratchpad" })
