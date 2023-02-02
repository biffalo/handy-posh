#! All-in-one IR script by Biff. Meant for IR use on Windows systems only. YMMV depending on what kind of logging you have enabled#
#! set hostname var as HN to keep things "clean"#
Write-host "Forensic Recon Starting" -ForegroundColor 'white' -BackgroundColor 'darkred'
$HN = $env:computername
mkdir .\$HN-log
#! get persistencesniper so we can import#
Invoke-WebRequest -Uri https://raw.githubusercontent.com/last-byte/PersistenceSniper/main/PersistenceSniper/PersistenceSniper.psm1 -OutFile .\PersistenceSniper.psm1
Invoke-WebRequest -Uri https://raw.githubusercontent.com/last-byte/PersistenceSniper/main/PersistenceSniper/PersistenceSniper.psd1 -OutFile .\PersistenceSniper.psd1
#! get running process network info#
Write-host "Gathering Process Info" -ForegroundColor 'white' -BackgroundColor 'darkred'
Get-NetTCPConnection | select LocalAddress,localport,remoteaddress,remoteport,state,@{name="process";Expression={(get-process -id $_.OwningProcess).ProcessName}}, @{Name="cmdline";Expression={(Get-WmiObject Win32_Process -filter "ProcessId = $($_.OwningProcess)").commandline}} | sort Remoteaddress -Descending | Export-Csv -Path .\$hn-log\$HN-Process-network.csv -NoTypeInformation
#! get running process with owner and cli info#
gwmi win32_process | Select Name,@{n='Owner';e={$_.GetOwner().User}},CommandLine -ErrorAction SilentlyContinue | Sort Name -unique -descending | Export-Csv -Path .\$hn-log\$HN-process-cli.csv -NoTypeInformation
#! get hash of running processes#
foreach ($proc in Get-Process | select path) {Get-FileHash $proc.path -Algorithm sha256 -ErrorAction SilentlyContinue | Export-Csv -Append -Path .\$hn-log\$HN-process-hash.csv -NoTypeInformation}
Write-host "Gathering Scheduled Task Info" -ForegroundColor 'white' -BackgroundColor 'darkred'
#! get scheduled task info#
schtasks /query /FO CSV /v | convertfrom-csv | where { $_.TaskName -ne "TaskName" } | select "TaskName","Run As User", Author, "Task to Run"| Export-Csv -Path .\$hn-log\$HN-schd-tasks.csv -NoTypeInformation
# !get running services and paths#
Write-host "Gathering Services Info" -ForegroundColor 'white' -BackgroundColor 'darkred'
Get-WmiObject win32_service |? State -match "running" | select Name, DisplayName, PathName, User | sort Name | Export-Csv -Path .\$hn-log\$HN-services.csv -NoTypeInformation
#! get prefetch so we can have rough history of exes run on the system#
Write-host "Gathering Prefetch Info" -ForegroundColor 'white' -BackgroundColor 'darkred'
Get-ChildItem C:\Windows\Prefetch | Select Name,LastWriteTime | Export-Csv -Path .\$hn-log\$HN-prefetch.csv -NoTypeInformation
#! get persistence using persistence sniper#
Write-host "Gathering Persistence Info" -ForegroundColor 'white' -BackgroundColor 'darkred'
Import-Module .\PersistenceSniper.psd1
Find-AllPersistence | Export-Csv -Path .\$hn-log\$HN-persistence.csv -NoTypeInformation
#! get event logs, but only ones that have been written to#
Write-host "Gathering Logs" -ForegroundColor 'white' -BackgroundColor 'darkred'
get-childitem C:\Windows\System32\winevt\Logs | where-object {$_.length -gt 69632} | Select -ExpandProperty FullName | Copy-Item -Destination .\$hn-log\
Write-host "Forensic Recon Complete - Forensic output can be found in the '$hn-log' folder in the folder that contains this script" -ForegroundColor 'white' -BackgroundColor 'darkred'
