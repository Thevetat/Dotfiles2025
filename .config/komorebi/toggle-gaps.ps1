$ErrorActionPreference = "Stop"

function Invoke-Komorebic {
    & komorebic @args
    if ($LASTEXITCODE -ne 0) {
        throw "komorebic failed with exit code $LASTEXITCODE"
    }
}

$marker = Join-Path $env:TEMP "komorebi-gaps-disabled"
$komorebi = Get-Process komorebi -ErrorAction Stop
$gapsAreDisabled = (Test-Path -LiteralPath $marker) -and
    (Get-Item -LiteralPath $marker).LastWriteTime -gt $komorebi.StartTime

if ($gapsAreDisabled) {
    Invoke-Komorebic focused-workspace-padding 4
    Invoke-Komorebic focused-workspace-container-padding 2
    Remove-Item -LiteralPath $marker -Force
} else {
    Invoke-Komorebic focused-workspace-padding 0
    Invoke-Komorebic "focused-workspace-container-padding" "--" "-1"
    New-Item -ItemType File -Path $marker -Force | Out-Null
}
