# ==============================================================================
# Installs uBlock Origin Lite (Manifest V3) in Google Chrome for all users
# ==============================================================================

# Ensure script runs with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Please run this PowerShell script as Administrator."
    return
}

# uBlock Origin Lite details
$extensionId  = 'ddkjiahejlhfcafbddmgiahcphecmpfh'
$updateUrl    = 'https://clients2.google.com/service/update2/crx'
$forceData    = "$extensionId;$updateUrl"

# Registry path for Chrome policies
$forcelistPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist'

# Create the policy registry key if it does not already exist
if (-not (Test-Path $forcelistPath)) {
    New-Item -Path $forcelistPath -Force | Out-Null
}

# (Optional) Clean up obsolete Manifest V2 temporary override if previously set
$chromePolicyPath = 'HKLM:\SOFTWARE\Policies\Google\Chrome'
if (Get-ItemProperty -Path $chromePolicyPath -Name "ExtensionManifestV2Availability" -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path $chromePolicyPath -Name "ExtensionManifestV2Availability" -Force -ErrorAction SilentlyContinue
}

# Check if uBlock Origin Lite is already in the forcelist, otherwise find the next available numeric slot
$existingProperties = Get-ItemProperty -Path $forcelistPath
$alreadyInstalled = $false
$nextIndex = 1

foreach ($prop in $existingProperties.PSObject.Properties) {
    if ($prop.Value -like "$extensionId;*") {
        $alreadyInstalled = $true
        break
    }
    if ($prop.Name -match '^\d+$') {
        $num = [int]$prop.Name
        if ($num -ge $nextIndex) {
            $nextIndex = $num + 1
        }
    }
}

if ($alreadyInstalled) {
    Write-Host "uBlock Origin Lite is already configured in Chrome's force-install policy." -ForegroundColor Yellow
} else {
    New-ItemProperty -Path $forcelistPath -Name $nextIndex.ToString() -Value $forceData -PropertyType String -Force | Out-Null
    Write-Host "Successfully configured uBlock Origin Lite (slot $nextIndex) for Chrome." -ForegroundColor Green
}
