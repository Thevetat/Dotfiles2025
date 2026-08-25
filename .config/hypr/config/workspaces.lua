-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR, default = true })

for workspace = 1, 5 do
  hl.workspace_rule({
    workspace = tostring(workspace),
    monitor = MONITOR1,
    default = true,
    persistent = true,
  })
end

hl.window_rule({
  match = { initial_title = "^CachyOS Scratch Terminal$" },
  tag = "+scratch-terminal",
  workspace = "special:scratch silent",
  float = true,
  center = true,
  size = { "min(monitor_w*0.72, 1800)", "min(monitor_h*0.72, 1000)" },
})

hl.window_rule({
  match = { initial_title = "^CachyOS Screensaver$" },
  tag = "+screensaver",
  fullscreen = true,
})
