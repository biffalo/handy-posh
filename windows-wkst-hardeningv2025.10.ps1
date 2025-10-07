<# 
    Windows 10/11 Hardening Script v2025.10  (by Biffalo)
    Fork/credit: https://gist.github.com/mackwage/08604751462126599d7e52f233490efe
    Notes:
      - Run as Administrator.
      - Designed to be low-breakage and idempotent.
      - HKCU settings are applied to all *loaded* user hives via HKU (good for RMM/at-scale).
      - For best coverage across future logons, push equivalent settings via GPO/Intune as well.
#>

#Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Utilities ---------------------------------------------------------------

function Ensure-Key {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
}

function Set-RegValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][ValidateSet('String','ExpandString','DWord','QWord','Binary','MultiString')][string]$Type,
        [Parameter()][object]$Value
    )
    Ensure-Key -Path $Path
    if (-not (Get-ItemProperty -LiteralPath $Path -Name $Name -ErrorAction SilentlyContinue)) {
        New-ItemProperty -LiteralPath $Path -Name $Name -PropertyType $Type -Value $Value -Force | Out-Null
    } else {
        Set-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -Force
    }
}

function Get-LoadedUserSidRoots {
    # Return only real user SIDs (skip system/builtin)
    Get-ChildItem -Path 'Registry::HKEY_USERS' -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match 'S-1-5-21-\d+-\d+-\d+-\d+$' } |
        ForEach-Object { "Registry::$($_.Name)" }
}

# --- 1) File association hardening (ransomware/common script types) ----------

Write-Host "[1/9] File association hardening..." -ForegroundColor Cyan
$typesToNotepad = @('htafile','wshfile','wsffile','jsfile','jsefile','vbefile','vbsfile')
foreach ($t in $typesToNotepad) {
    # Use ftype externally—safe and reversible; keeps your previous behavior
    cmd /c "ftype $t=""$env:SystemRoot\system32\NOTEPAD.EXE"" ""%1""" | Out-Null
}

# --- 2) Block ISO/VHD mounting in Explorer ----------------------------------

Write-Host "[2/9] Disabling ISO/VHD context mounting..." -ForegroundColor Cyan
# Setting ProgrammaticAccessOnly (string) present disables GUI mount verb
Set-RegValue -Path 'Registry::HKEY_CLASSES_ROOT\Windows.IsoFile\shell\mount' -Name 'ProgrammaticAccessOnly' -Type String -Value ''
Set-RegValue -Path 'Registry::HKEY_CLASSES_ROOT\Windows.VhdFile\shell\mount' -Name 'ProgrammaticAccessOnly' -Type String -Value ''

# --- 3) Early Launch Anti-Malware (ELAM) -------------------------------------

Write-Host "[3/9] Configuring ELAM (boot-start driver policy)..." -ForegroundColor Cyan
# 3 = default (good + unknown + bad but critical). Consider 1 or 8 if your fleet tolerates it.
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Policies\EarlyLaunch' -Name 'DriverLoadPolicy' -Type DWord -Value 3

# --- 4) OneNote hardening (per-user HKCU via HKU) ----------------------------

Write-Host "[4/9] OneNote hardening for loaded user profiles..." -ForegroundColor Cyan
$oneNoteOptionGlobs = @('\Software\Microsoft\Office\*\OneNote\Options')
foreach ($sidRoot in Get-LoadedUserSidRoots) {
    foreach ($glob in $oneNoteOptionGlobs) {
        foreach ($optionsKey in (Get-ChildItem -Path ($sidRoot + $glob) -ErrorAction SilentlyContinue)) {
            $optPath = $optionsKey.PSPath
            Set-RegValue -Path $optPath -Name 'disableembeddedfiles' -Type DWord -Value 1
            $embedPath = Join-Path $optPath '_embeddedfileopenoptions'
            Ensure-Key -Path $embedPath
            Set-RegValue -Path $embedPath -Name 'blockedextensions' -Type String -Value '.js;.exe;.bat;.vbs;.com;.scr;.cmd;.ps1;.zip;.dll'
        }
    }
}

# --- 5) Browser & SmartScreen settings ---------------------------------------

Write-Host "[5/9] Browser/SmartScreen & general security policies..." -ForegroundColor Cyan
# Modern Chromium Edge policy location
# Enable SmartScreen, disable built-in password manager (promote enterprise PM)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'SmartScreenEnabled'     -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Edge' -Name 'PasswordManagerEnabled' -Type DWord -Value 0

# System SmartScreen
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'EnableSmartScreen'    -Type DWord  -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'ShellSmartScreenLevel' -Type String -Value 'Warn'

# Installer scripting notifications (IE legacy control—kept for parity)
Set-RegValue -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Installer' -Name 'SafeForScripting' -Type DWord -Value 0

# --- 6) Removable media & LSASS protections ---------------------------------

# Disable autorun/autoplay
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'                         -Name 'NoAutoplayfornonVolume' -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'          -Name 'NoDriveTypeAutoRun'    -Type DWord -Value 255
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'          -Name 'NoAutorun'             -Type DWord -Value 1

# LSASS: protect process, audit, restrict credential export
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe' -Name 'AuditLevel'     -Type DWord -Value 8
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa'                                                -Name 'RunAsPPL'       -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'                           -Name 'AllowProtectedCreds' -Type DWord -Value 1

# RPC hardening
Set-RegValue -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Schedule' -Name 'DisableRpcOverTcp'     -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control'                         -Name 'DisableRemoteScmEndpoints' -Type DWord -Value 1

# Biometrics & lock protections
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Biometrics\FacialFeatures' -Name 'EnhancedAntiSpoofing'              -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'   -Name 'NoLockScreenCamera'                -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy'        -Name 'LetAppsActivateWithVoiceAboveLock' -Type DWord -Value 2  # 2 = Force Deny

# --- 7) Windows Firewall + logging + Defender Network Protection --------------

Write-Host "[6/9] Enabling Windows Firewall and logging..." -ForegroundColor Cyan
# Enable firewall across profiles
'Domain','Private','Public' | ForEach-Object {
    Set-NetFirewallProfile -Profile $_ -Enabled True
    # Logging
    Set-NetFirewallProfile -Profile $_ -LogFileName "$env:SystemRoot\system32\LogFiles\Firewall\pfirewall.log"
    Set-NetFirewallProfile -Profile $_ -LogMaxSizeKilobytes 4096
    Set-NetFirewallProfile -Profile $_ -LogBlocked True -LogAllowed False
}

# Defender Network Protection (requires Defender AV)
Write-Host "Enabling Defender Network Protection..." -ForegroundColor DarkCyan
Try { Set-MpPreference -EnableNetworkProtection Enabled } Catch { Write-Warning $_ }

# Block suspicious netconns from frequently abused native binaries
Write-Host "Adding outbound block rules for LOLBINs..." -ForegroundColor DarkCyan
$binPaths = @(
    "$env:WINDIR\system32\notepad.exe",
    "$env:WINDIR\system32\regsvr32.exe",
    "$env:WINDIR\system32\calc.exe",
    "$env:WINDIR\system32\mshta.exe",
    "$env:WINDIR\system32\wscript.exe",
    "$env:WINDIR\system32\cscript.exe",
    "$env:WINDIR\system32\runscripthelper.exe",
    "$env:WINDIR\system32\hh.exe"
)
foreach ($p in $binPaths) {
    $name = "Block outbound: $(Split-Path $p -Leaf)"
    if (-not (Get-NetFirewallApplicationFilter -PolicyStore ActiveStore -ErrorAction SilentlyContinue | Where-Object { $_.Program -ieq $p })) {
        New-NetFirewallRule -DisplayName $name -Direction Outbound -Action Block -Program $p -Profile Any -Protocol TCP -Enabled True | Out-Null
    }
}

# --- 8) Privacy controls -----------------------------------------------------

Write-Host "[7/9] Applying privacy controls..." -ForegroundColor Cyan
# Telemetry: 0 allowed only on Enterprise/Education; set 1 on Home/Pro to avoid policy conflict
$edition = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').EditionID
$allowTelemetry = if ($edition -in @('Enterprise','EnterpriseS','Education')) { 0 } else { 1 }
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry'                         -Type DWord -Value $allowTelemetry
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'MaxTelemetryAllowed'                    -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack' -Name 'ShowedToastAtLevel'        -Type DWord -Value 1
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'LimitEnhancedDiagnosticDataWindowsAnalytics' -Type DWord -Value 1

# Disable Microsoft consumer experience & app suggestions (system + per-user)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' -Name 'DisableWindowsConsumerFeatures' -Type DWord -Value 1

foreach ($sidRoot in Get-LoadedUserSidRoots) {
    # Location: CapabilityAccessManager\ConsentStore\location -> "Value"="Deny"
    $locPath = "$sidRoot\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    Set-RegValue -Path $locPath -Name 'Value' -Type String -Value 'Deny'

    # Start menu/web search & location use
    Set-RegValue -Path "$sidRoot\Software\Microsoft\Windows\CurrentVersion\Search" -Name 'BingSearchEnabled'         -Type DWord -Value 0
    Set-RegValue -Path "$sidRoot\Software\Microsoft\Windows\CurrentVersion\Search" -Name 'AllowSearchToUseLocation'  -Type DWord -Value 0
    Set-RegValue -Path "$sidRoot\Software\Microsoft\Windows\CurrentVersion\Search" -Name 'CortanaConsent'            -Type DWord -Value 0

    # Content Delivery (quiet the recommendations)
    $cdm = "$sidRoot\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-RegValue -Path $cdm -Name 'SystemPaneSuggestionsEnabled' -Type DWord -Value 0
    Set-RegValue -Path $cdm -Name 'SilentInstalledAppsEnabled'   -Type DWord -Value 0
    Set-RegValue -Path $cdm -Name 'PreInstalledAppsEnabled'      -Type DWord -Value 0
    Set-RegValue -Path $cdm -Name 'OemPreInstalledAppsEnabled'   -Type DWord -Value 0

    # Language list privacy
    Set-RegValue -Path "$sidRoot\Control Panel\International\User Profile" -Name 'HttpAcceptLanguageOptOut' -Type DWord -Value 1
}

# Disable activity publishing & settings sync; disable advertising ID
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'        -Name 'PublishUserActivities'     -Type DWord -Value 0
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'   -Name 'DisableSettingSync'        -Type DWord -Value 2
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' -Name 'DisabledByGroupPolicy'   -Type DWord -Value 1

# GameDVR (disable)
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' -Name 'AllowGameDVR' -Type DWord -Value 0

# Lock-screen toast suppression
Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications' -Name 'NoToastApplicationNotificationOnLockScreen' -Type DWord -Value 1

# --- 9) Final state ----------------------------------------------------------

Write-Host "[8/9] Verifying Defender AV presence (optional)..." -ForegroundColor Cyan
try {
    $mp = Get-MpComputerStatus -ErrorAction Stop
    Write-Host ("  Defender AM Service: {0}, RealTime: {1}, Antispyware: {2}" -f $mp.AMServiceEnabled, $mp.RealTimeProtectionEnabled, $mp.AntispywareEnabled)
} catch { Write-Host "  Defender module not available or not the active AV. Skipping status." -ForegroundColor Yellow }

Write-Host "[9/9] Complete. Some per-user settings apply to currently loaded user hives; deploy via GPO/Intune for persistence across new users." -ForegroundColor Green
