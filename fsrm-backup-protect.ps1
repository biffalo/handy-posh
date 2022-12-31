#configured FSRM to only allow certain file types and block all others. If an attempt is made to change the file ext to restricted one or write a restricted one an event is logged#
Import-Module FileServerResourceManager
$RansomeWareFileGroupName = "BackupProtect"
$RansomwareTemplateName = "BackupProtect"
$Path = Read-Host "Enter Path to local backup location IE 'E:\backup'" 
$Notification = New-FsrmAction -Type Event -EventType Warning -Body "User [Source Io Owner] attempted to save [Source File Path] to [File Screen Path] on the [Server] server. This file is in the [Violated File Group] file group, which is not permitted on the server and suggests a ransomware attack has been attempted." -RunLimitInterval 10
Write-Host "Backup Protector  v1 -by Biffalo" -ForegroundColor Green -BackgroundColor Black
Write-Host "Installing FSRM..." -ForegroundColor Green -BackgroundColor Black
Add-WindowsFeature –Name FS-Resource-Manager –IncludeManagementTools
Write-Host "Creating filegroup.." -ForegroundColor Green -BackgroundColor Black
New-FsrmFileGroup -name $RansomeWareFileGroupName -IncludePattern @("*.*") -ExcludePattern @("*.LCK","*.txt","*.tib","*.xml","*.chk")
Write-Host "Creating FileScreen Template and Filescreen..." -ForegroundColor Green -BackgroundColor Black
New-FsrmFileScreenTemplate -Name $RansomwareTemplateName -IncludeGroup $RansomeWareFileGroupName -Description "Backup Protector Protector" -Notification $Notification -Active
New-FsrmFileScreen -Path "$Path" -Template $RansomwareTemplateName
Write-Host "If you see red text above indicating an error the server needs to be rebooted and the script rerun to complete the install." -ForegroundColor Green -BackgroundColor Black