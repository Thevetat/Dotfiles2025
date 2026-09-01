# Applies the tracked terminal appearance without replacing generated profiles.
$ErrorActionPreference = 'Stop'

function Set-JsonProperty {
    param(
        [Parameter(Mandatory)] [object] $InputObject,
        [Parameter(Mandatory)] [string] $Name,
        [Parameter(Mandatory)] $Value
    )

    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -eq $property) {
        $InputObject | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    } else {
        $property.Value = $Value
    }
}

$settingsPath = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
if (!(Test-Path -LiteralPath $settingsPath)) {
    throw "Windows Terminal settings not found: $settingsPath"
}

$settings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
$ubuntu = $settings.profiles.list |
    Where-Object { $_.source -eq 'CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc' } |
    Select-Object -First 1

if ($null -eq $ubuntu) {
    throw 'The Ubuntu Windows Terminal profile is not installed.'
}

Set-JsonProperty $settings 'defaultProfile' $ubuntu.guid
Set-JsonProperty $settings 'copyFormatting' 'none'
Set-JsonProperty $settings 'copyOnSelect' $true
Set-JsonProperty $settings 'warning.confirmCloseAllTabs' $false
Set-JsonProperty $settings 'theme' 'dark'

$font = [ordered]@{
    face = 'JetBrainsMono NF'
    size = 15
}

$defaults = $settings.profiles.defaults
Set-JsonProperty $defaults 'colorScheme' 'Tokyo Night Storm'
Set-JsonProperty $defaults 'cursorShape' 'filledBox'
Set-JsonProperty $defaults 'font' $font
Set-JsonProperty $defaults 'opacity' 95
Set-JsonProperty $defaults 'padding' '8'
Set-JsonProperty $defaults 'useAcrylic' $true

$scheme = [ordered]@{
    background          = '#24283B'
    black               = '#1D202F'
    blue                = '#7AA2F7'
    brightBlack         = '#414868'
    brightBlue          = '#7AA2F7'
    brightCyan          = '#7DCFFF'
    brightGreen         = '#9ECE6A'
    brightPurple        = '#9D7CD8'
    brightRed           = '#F7768E'
    brightWhite         = '#C0CAF5'
    brightYellow        = '#E0AF68'
    cursorColor         = '#C0CAF5'
    cyan                = '#7DCFFF'
    foreground          = '#C0CAF5'
    green               = '#9ECE6A'
    name                = 'Tokyo Night Storm'
    purple              = '#BB9AF7'
    red                 = '#F7768E'
    selectionBackground = '#2E3C64'
    white               = '#A9B1D6'
    yellow              = '#E0AF68'
}

$otherSchemes = @($settings.schemes | Where-Object { $_.name -ne $scheme.name })
Set-JsonProperty $settings 'schemes' @($otherSchemes + [pscustomobject] $scheme)

$json = $settings | ConvertTo-Json -Depth 100
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($settingsPath, $json + [Environment]::NewLine, $utf8NoBom)

Write-Output "Configured Windows Terminal: $settingsPath"
