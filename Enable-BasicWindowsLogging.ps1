#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Enables a practical baseline of Windows security logging.

.DESCRIPTION
    Configures bounded event-log sizes, process and PowerShell telemetry, and a
    focused set of advanced audit-policy subcategories.

    Run in an elevated Windows PowerShell 5.1 session. Domain Group Policy may
    override these local settings. The script is intended for Windows 10/11 and
    Windows Server 2016 or later.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:FailureCount = 0

function Set-EventLogConfiguration {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogName,

        [Parameter(Mandatory = $true)]
        [long]$MaximumSizeBytes
    )

    try {
        & "$env:SystemRoot\System32\wevtutil.exe" sl $LogName `
            "/ms:$MaximumSizeBytes" /rt:false /ab:false 2>$null

        if ($LASTEXITCODE -ne 0) {
            throw "wevtutil exited with code $LASTEXITCODE."
        }
    }
    catch {
        Write-Warning "Failed to configure event log '$LogName': $($_.Exception.Message)"
        $script:FailureCount++
    }
}

function Set-RegistryDword {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [int]$Value
    )

    try {
        if (-not (Test-Path -LiteralPath $Path)) {
            $null = New-Item -Path $Path -Force
        }

        $null = New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value `
            -PropertyType DWord -Force
    }
    catch {
        Write-Warning "Failed to set registry value '$Path\$Name': $($_.Exception.Message)"
        $script:FailureCount++
    }
}

function Set-AdvancedAuditPolicy {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Subcategory,

        [Parameter(Mandatory = $true)]
        [ValidateSet('enable', 'disable')]
        [string]$Success,

        [Parameter(Mandatory = $true)]
        [ValidateSet('enable', 'disable')]
        [string]$Failure
    )

    try {
        & "$env:SystemRoot\System32\auditpol.exe" /set `
            "/subcategory:$Subcategory" "/success:$Success" "/failure:$Failure" 2>$null

        if ($LASTEXITCODE -ne 0) {
            throw "auditpol exited with code $LASTEXITCODE."
        }
    }
    catch {
        Write-Warning "Failed to configure audit policy '$Subcategory': $($_.Exception.Message)"
        $script:FailureCount++
    }
}

Write-Host 'Configuring bounded Windows event logs...'

# Security reason: Larger logs preserve more forensic history after an incident.
# Fixed maximum sizes and overwrite-oldest behavior prevent logging from consuming
# unbounded disk space, which could otherwise cause availability problems.
$eventLogs = @(
    @{ Name = 'Security';                                 MaximumSizeBytes = 256MB }
    @{ Name = 'System';                                   MaximumSizeBytes = 64MB }
    @{ Name = 'Application';                              MaximumSizeBytes = 64MB }
    @{ Name = 'Windows PowerShell';                       MaximumSizeBytes = 32MB }
    @{ Name = 'Microsoft-Windows-PowerShell/Operational'; MaximumSizeBytes = 128MB }
)

foreach ($eventLog in $eventLogs) {
    Set-EventLogConfiguration -LogName $eventLog.Name `
        -MaximumSizeBytes $eventLog.MaximumSizeBytes
}

Write-Host 'Configuring process and PowerShell logging...'

# Security reason: Advanced audit subcategories provide precise control over the
# events collected. Forcing them to override legacy category policy prevents a
# broader legacy setting from silently weakening this focused audit baseline.
Set-RegistryDword `
    -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' `
    -Name 'SCENoApplyLegacyAuditPolicy' `
    -Value 1

# Security reason: Including command lines in successful process-creation event
# 4688 helps identify malicious tools, scripts, and suspicious arguments.
# Privacy warning: Command lines can also contain passwords, tokens, file paths,
# or other sensitive data, so access to the Security log should remain restricted.
Set-RegistryDword `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit' `
    -Name 'ProcessCreationIncludeCmdLine_Enabled' `
    -Value 1

# Security reason: Script block logging records de-obfuscated PowerShell code and
# is valuable for detecting fileless attacks and reconstructing attacker actions.
# Invocation and broad module logging remain disabled to reduce duplicate events,
# sensitive-data exposure, and log volume for this basic endpoint baseline.
$scriptBlockLoggingPath =
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
$moduleLoggingPath =
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging'

Set-RegistryDword -Path $scriptBlockLoggingPath `
    -Name 'EnableScriptBlockLogging' -Value 1
Set-RegistryDword -Path $scriptBlockLoggingPath `
    -Name 'EnableScriptBlockInvocationLogging' -Value 0
Set-RegistryDword -Path $moduleLoggingPath `
    -Name 'EnableModuleLogging' -Value 0

Write-Host 'Configuring focused advanced audit policy...'

# Security reason: Account and group-management events expose privilege changes,
# account creation or deletion, and persistence through group membership changes.
Set-AdvancedAuditPolicy -Subcategory 'Security Group Management' `
    -Success enable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'User Account Management' `
    -Success enable -Failure enable

# Security reason: Authentication and session events reveal successful access,
# password guessing, lockouts, administrative logons, and when sessions end.
Set-AdvancedAuditPolicy -Subcategory 'Account Lockout' `
    -Success enable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'Logon' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'Logoff' `
    -Success enable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'Special Logon' `
    -Success enable -Failure disable

# Security reason: Process-creation events establish which programs ran and,
# together with event 4688 command-line logging, provide a useful execution trail.
Set-AdvancedAuditPolicy -Subcategory 'Process Creation' `
    -Success enable -Failure disable

# Security reason: Removable-storage events help detect data theft, unauthorized
# software transfer, and malware introduced through USB or similar media.
Set-AdvancedAuditPolicy -Subcategory 'Removable Storage' `
    -Success enable -Failure enable

# Security reason: Audit, authentication, and firewall policy changes can indicate
# defense evasion, weakened access controls, or unauthorized network exposure.
Set-AdvancedAuditPolicy -Subcategory 'Audit Policy Change' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'Authentication Policy Change' `
    -Success enable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'Filtering Platform Policy Change' `
    -Success enable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'MPSSVC Rule-Level Policy Change' `
    -Success enable -Failure disable

# Security reason: Core system events expose integrity failures, security-service
# changes, extension loading, startup or shutdown state, and IPsec problems that
# may indicate tampering or a degraded security posture.
Set-AdvancedAuditPolicy -Subcategory 'IPsec Driver' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'Other System Events' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'Security State Change' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'Security System Extension' `
    -Success enable -Failure enable
Set-AdvancedAuditPolicy -Subcategory 'System Integrity' `
    -Success enable -Failure enable

# Security reason: Per-connection and packet-drop auditing can assist detailed
# network investigations, but it generates several events per connection and can
# quickly bury higher-value endpoint signals. It is explicitly disabled here to
# keep this baseline usable; enable it selectively when deeper telemetry is needed.
Set-AdvancedAuditPolicy -Subcategory 'Filtering Platform Connection' `
    -Success disable -Failure disable
Set-AdvancedAuditPolicy -Subcategory 'Filtering Platform Packet Drop' `
    -Success disable -Failure disable

Write-Host ''

if ($script:FailureCount -eq 0) {
    Write-Host 'Windows logging configuration completed successfully.'
    exit 0
}

Write-Warning (
    "Configuration completed with $script:FailureCount failed operation(s). " +
    'Review Group Policy, Windows edition support, and event-log availability.'
)
exit 1
