# Windows

Windows-specific configuration is rooted here rather than mixed into the
portable Unix-style dotfiles tree.

## Setup

Run from PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\setup.ps1
```

The setup script installs required packages, configures the `Win` key as the
Super modifier, starts komorebi with AutoHotkey, creates Startup shortcuts,
and applies the Windows Terminal appearance.

## Layout

- `komorebi/komorebi.ahk`: Super-key bindings backed by komorebi
- `windows-terminal/setup.ps1`: Ubuntu default and Tokyo Night Storm settings
- `setup.ps1`: idempotent Windows bootstrap

The existing live komorebi engine configuration remains in
`~/.config/komorebi`. `KOMOREBI_CONFIG_HOME` points there while AutoHotkey runs
directly from this directory.

## Important Bindings

- `Win+H/J/K/L`: focus tiled windows
- `Win+Shift+H/J/K/L`: move tiled windows
- `Win+1-8`: focus a workspace
- `Win+Shift+1-8`: move a window to a workspace
- `Win+Enter`: Ubuntu with the main tmux session
- `Win+Ctrl+Enter`: plain Ubuntu
- `Win+S`: Windows Terminal quake window
- `Win+Shift+O`: focus or launch Obsidian
- `Win+Space`: Raycast, intentionally not intercepted by AutoHotkey

`DisableLockWorkstation=1` frees `Win+L` for focus-right. This disables all
Windows workstation locking for the current user and may require one sign-out
or restart after first setup.
