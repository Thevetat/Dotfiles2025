$ErrorActionPreference = "Stop"

$layout = komorebic query focused-workspace-layout
if ($LASTEXITCODE -ne 0) {
    throw "Could not query the focused workspace layout"
}

if ($layout -eq "UltrawideVerticalStack") {
    komorebic change-layout columns
} else {
    komorebic change-layout ultrawide-vertical-stack
}

if ($LASTEXITCODE -ne 0) {
    throw "Could not change the focused workspace layout"
}
