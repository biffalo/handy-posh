# Automates logmira gpo import and setup for any domain controller to save manual work
# https://support.blumira.com/hc/en-us/articles/4995491084947-Advanced-Microsoft-Windows-logging-with-Logmira-GPO-template#h_01HGBJB245C9QVNNXGY1RNREP6
# SETTINGS
$GPO_URL = "https://github.com/Blumira/Logmira/raw/master/GPO%20Files/Logmira.zip"
$LocalZip = "$env:TEMP\Logmira.zip"
$ExtractedPath = "$env:TEMP\Logmira-GPO"
$GPOName = "Logmira"
$BackupDisplayName = "Logmira"

# Download and Extract Logmira.zip
Invoke-WebRequest -Uri $GPO_URL -OutFile $LocalZip -UseBasicParsing
if (Test-Path $ExtractedPath) { Remove-Item -Path $ExtractedPath -Recurse -Force }
Expand-Archive -Path $LocalZip -DestinationPath $ExtractedPath -Force

# Find the Backup.xml (recursively, for any depth)
$BackupXml = Get-ChildItem -Path $ExtractedPath -Recurse -Filter "Backup.xml" | Select-Object -First 1
if (-not $BackupXml) { throw "No Backup.xml found after extracting Logmira.zip. Check extraction!" }

[xml]$BackupData = Get-Content $BackupXml.FullName
$BackupDisplayName = $BackupData.BackupGPO.BackupGPOName
Write-Host "Found GPO backup with display name: $BackupDisplayName"

# The parent of Backup.xml is the GUID folder; its parent is the backup path to use for Import-GPO
$BackupFolder = Split-Path -Parent $BackupXml.FullName
$ImportPath = Split-Path -Parent $BackupFolder

# Create or reuse the GPO
if (-not (Get-GPO -Name $GPOName -ErrorAction SilentlyContinue)) {
    New-GPO -Name $GPOName | Out-Null
}

# Now import from the correct parent directory
Import-GPO -BackupGpoName "Logmira" -Path $ImportPath -TargetName $GPOName -CreateIfNeeded

# Link the GPO to the domain root
$DomainDN = (Get-ADDomain).DistinguishedName

try {
    New-GPLink -Name $GPOName -Target $DomainDN -Enforced No -ErrorAction Stop
    Write-Host "Successfully linked GPO '$GPOName' to domain root $DomainDN."
} catch {
    Write-Host "Failed to link GPO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nLogmira GPO imported and linked to $DomainDN!" -ForegroundColor Green

# ---- Security Filtering Section ----

# Add Domain Users, Domain Computers, Domain Controllers with GpoApply rights
$groups = @("Domain Users", "Domain Computers", "Domain Controllers")
foreach ($group in $groups) {
    try {
        Set-GPPermission -Name $GPOName -TargetName $group -TargetType Group -PermissionLevel GpoApply -ErrorAction Stop
        Write-Host "Granted GPO Apply permission to '$group'"
    } catch {
        Write-Host "Failed to set GPO Apply for $group- $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`nSecurity filtering set: Domain Users, Domain Computers, Domain Controllers" -ForegroundColor Green
