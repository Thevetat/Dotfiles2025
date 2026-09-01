$ErrorActionPreference = 'Stop'

function Install-WingetPackage {
    param([Parameter(Mandatory)] [string] $Id)

    & winget.exe list --id $Id --exact --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        return
    }

    & winget.exe install --id $Id --exact --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install winget package: $Id"
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$configHome = Join-Path $HOME '.config\komorebi'
$komorebiConfig = Join-Path $configHome 'komorebi.json'
$ahkScript = Join-Path $PSScriptRoot 'komorebi\komorebi.ahk'
$terminalSetup = Join-Path $PSScriptRoot 'windows-terminal\setup.ps1'

foreach ($path in @($komorebiConfig, $ahkScript, $terminalSetup)) {
    if (!(Test-Path -LiteralPath $path)) {
        throw "Required Windows setup file not found: $path"
    }
}

if (!(Get-Command komorebic.exe -ErrorAction SilentlyContinue)) {
    Install-WingetPackage 'LGUG2Z.komorebi'
}
Install-WingetPackage 'AutoHotkey.AutoHotkey'
Install-WingetPackage 'DEVCOM.JetBrainsMonoNerdFont'

[Environment]::SetEnvironmentVariable('KOMOREBI_CONFIG_HOME', $configHome, 'User')
$env:KOMOREBI_CONFIG_HOME = $configHome

$policyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System'
$policy = Get-ItemProperty -LiteralPath $policyPath -Name DisableLockWorkstation -ErrorAction SilentlyContinue
if ($null -eq $policy -or $policy.DisableLockWorkstation -ne 1) {
    $reg = Start-Process -FilePath "$env:WINDIR\System32\reg.exe" -Verb RunAs -Wait -PassThru -ArgumentList @(
        'add',
        'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System',
        '/v', 'DisableLockWorkstation',
        '/t', 'REG_DWORD',
        '/d', '1',
        '/f'
    )
    if ($reg.ExitCode -ne 0) {
        throw 'Failed to disable the Windows lock shortcut.'
    }
}

$applicationsConfig = Join-Path $configHome 'applications.json'
if (!(Test-Path -LiteralPath $applicationsConfig)) {
    & komorebic.exe fetch-asc
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to fetch komorebi application-specific configuration.'
    }
}

Get-Process whkd -ErrorAction SilentlyContinue | Stop-Process -Force

if (Get-Process komorebi -ErrorAction SilentlyContinue) {
    & komorebic.exe reload-configuration
} else {
    & komorebic.exe start --config $komorebiConfig
}
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to start or reload komorebi.'
}

& komorebic.exe disable-autostart
& komorebic.exe enable-autostart --config $komorebiConfig
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to configure komorebi autostart.'
}

$autoHotkey = Join-Path $env:LOCALAPPDATA 'Programs\AutoHotkey\v2\AutoHotkey64.exe'
if (!(Test-Path -LiteralPath $autoHotkey)) {
    throw "AutoHotkey executable not found: $autoHotkey"
}

Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq 'AutoHotkey64.exe' -and $_.CommandLine -like '*komorebi.ahk*' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

Start-Process -FilePath $autoHotkey -ArgumentList "`"$ahkScript`""

$startup = [Environment]::GetFolderPath('Startup')
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut((Join-Path $startup 'komorebi-autohotkey.lnk'))
$shortcut.TargetPath = $autoHotkey
$shortcut.Arguments = "`"$ahkScript`""
$shortcut.WorkingDirectory = Split-Path -Parent $ahkScript
$shortcut.Description = 'Komorebi Super-key bindings'
$shortcut.Save()

& $terminalSetup

Write-Output "Configured Windows integration from: $repoRoot"
