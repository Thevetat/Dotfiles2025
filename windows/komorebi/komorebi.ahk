#Requires AutoHotkey v2.0.2
#SingleInstance Force
#UseHook True

SetWorkingDir A_ScriptDir

Komorebic(command) {
    RunWait(Format("komorebic.exe {}", command), , "Hide")
}

RunPowerShellScript(scriptName) {
    configHome := EnvGet("KOMOREBI_CONFIG_HOME")
    if configHome = ""
        configHome := A_UserProfile "\.config\komorebi"

    command := Format(
        "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"{}`"",
        configHome "\" scriptName
    )
    RunWait(command, , "Hide")
}

RunWsl(command := "") {
    wslCommand := "wsl.exe -d Ubuntu --cd ~"
    if command != ""
        wslCommand .= " --exec " command
    Run(Format("wt.exe -w new {}", wslCommand))
}

RunApp(executable, arguments := "") {
    command := Format("`"{}`"", executable)
    if arguments != ""
        command .= " " arguments
    Run(command)
}

FocusOrRun(processName, executable, arguments := "") {
    if hwnd := WinExist("ahk_exe " processName) {
        WinActivate("ahk_id " hwnd)
        return
    }
    RunApp(executable, arguments)
}

IsTerminal() {
    try processName := StrLower(WinGetProcessName("A"))
    catch
        return false

    return processName = "windowsterminal.exe"
        || processName = "alacritty.exe"
        || processName = "wezterm-gui.exe"
        || processName = "ghostty.exe"
}

InsertNewWindow(direction) {
    Komorebic("preselect-direction " direction)
    Send("^n")
}

; Window management: mirrors ~/.config/hypr/config/binds.lua.
#w::Komorebic("close")
#q::Komorebic("close")
#t::Komorebic("toggle-float")
#f::Komorebic("toggle-monocle")
#!f::Komorebic("toggle-maximize")
#^f::Komorebic("toggle-monocle")
#e::Komorebic("retile")
#o::Komorebic("toggle-float")
#g::Komorebic("toggle-workspace-window-container-behaviour")
#Backspace::Komorebic("toggle-transparency")

; Directional focus and movement.
#h::Komorebic("focus left")
#j::Komorebic("focus down")
#k::Komorebic("focus up")
#l::Komorebic("focus right")
#+h::Komorebic("move left")
#+j::Komorebic("move down")
#+k::Komorebic("move up")
#+l::Komorebic("move right")

; Resize the focused container.
#=::Komorebic("resize-axis horizontal increase")
#-::Komorebic("resize-axis horizontal decrease")
#+=::Komorebic("resize-axis vertical increase")
#+_::Komorebic("resize-axis vertical decrease")

; Workspaces are zero-indexed by komorebi.
#1::Komorebic("focus-workspace 0")
#2::Komorebic("focus-workspace 1")
#3::Komorebic("focus-workspace 2")
#4::Komorebic("focus-workspace 3")
#5::Komorebic("focus-workspace 4")
#6::Komorebic("focus-workspace 5")
#7::Komorebic("focus-workspace 6")
#8::Komorebic("focus-workspace 7")
#+1::Komorebic("move-to-workspace 0")
#+2::Komorebic("move-to-workspace 1")
#+3::Komorebic("move-to-workspace 2")
#+4::Komorebic("move-to-workspace 3")
#+5::Komorebic("move-to-workspace 4")
#+6::Komorebic("move-to-workspace 5")
#+7::Komorebic("move-to-workspace 6")
#+8::Komorebic("move-to-workspace 7")
#Tab::Komorebic("cycle-workspace next")
#+Tab::Komorebic("cycle-workspace previous")
#^Tab::Komorebic("focus-last-workspace")
#!h::Komorebic("cycle-workspace previous")
#!l::Komorebic("cycle-workspace next")
#+!h::Komorebic("cycle-move-to-workspace previous")
#+!l::Komorebic("cycle-move-to-workspace next")

; Applications and scratch terminals.
#Enter::RunWsl("/home/thevetat/.local/bin/launch-main-terminal")
#^Enter::RunWsl()
#s::Run("wt.exe -w _quake")
#+f::Run("explorer.exe")
#+n::RunWsl("/usr/bin/nvim")
#^t::RunWsl("/usr/bin/btop")
#n::Run("notepad.exe")
#+Enter::FocusOrRun("zen.exe", "C:\Program Files\Zen Browser\zen.exe")
#+^Enter::RunApp("C:\Program Files\Zen Browser\zen.exe", "--new-window")
#+!Enter::RunApp("C:\Program Files\Zen Browser\zen.exe", "--private-window")
#+o::FocusOrRun("Obsidian.exe", EnvGet("LOCALAPPDATA") "\Programs\Obsidian\Obsidian.exe")
#+e::FocusOrRun("Proton Mail.exe", EnvGet("LOCALAPPDATA") "\proton_mail\Proton Mail.exe")

; Universal clipboard. Terminal copy and paste avoid colliding with SIGINT.
$#c::Send(IsTerminal() ? "^{Insert}" : "^c")
$#v::Send(IsTerminal() ? "+{Insert}" : "^v")
$#x::Send("^x")
#^v::Send("#v")

; Win+L is directional focus. DisableLockWorkstation must remain enabled so
; Windows does not consume the chord before AutoHotkey receives it.

; Preserve useful controls from the previous Windows configuration.
!o::Reload()
!+o::Komorebic("reload-configuration")
!i::Komorebic("toggle-shortcuts")
^+f::Komorebic("toggle-float")
!+f::Komorebic("toggle-monocle")
!f::Komorebic("promote")
!+s::RunPowerShellScript("toggle-stack-layout.ps1")
!+x::Komorebic("flip-layout horizontal")
!+y::Komorebic("flip-layout vertical")
^!h::Komorebic("resize-edge left increase")
^!j::Komorebic("resize-edge down increase")
^!k::Komorebic("resize-edge up increase")
^!l::Komorebic("resize-edge right increase")
^!e::Komorebic("retile")
^!g::RunPowerShellScript("toggle-gaps.ps1")
^!b::Komorebic("border disable")
^!+b::Komorebic("border enable")
^!+h::Komorebic("preselect-direction left")
^!+j::Komorebic("preselect-direction down")
^!+k::Komorebic("preselect-direction up")
^!+l::Komorebic("preselect-direction right")
^!+s::Komorebic("toggle-workspace-window-container-behaviour")
!s::InsertNewWindow("right")
!v::InsertNewWindow("down")
!t::RunWsl()
!+t::Komorebic("retile")
!+r::Komorebic("reload-configuration")
