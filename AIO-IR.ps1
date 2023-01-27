#All-in-one IR script by Biff. Meant for IR use on Windows systems only. YMMV depending on what kind of logging you have enabled#
#this requires Persistence Sniper be in the same folder as this script. Get it from https://github.com/last-byte/PersistenceSniper/tree/main/PersistenceSniper#
#set hostname var as HN to keep things "clean"#
$HN = $env:computername
Write-host "Forensic Recon Starting"
#get running process network info#
Write-host "Gathering Process Info"
Get-NetTCPConnection | select LocalAddress,localport,remoteaddress,remoteport,state,@{name="process";Expression={(get-process -id $_.OwningProcess).ProcessName}}, @{Name="cmdline";Expression={(Get-WmiObject Win32_Process -filter "ProcessId = $($_.OwningProcess)").commandline}} | sort Remoteaddress -Descending | Export-Csv -Path .\$HN-Process-network.csv -NoTypeInformation
#get running process with owner and cli info#
gwmi win32_process | Select Name,@{n='Owner';e={$_.GetOwner().User}},CommandLine -ErrorAction SilentlyContinue | Sort Name -unique -descending | Export-Csv -Path .\$HN-process-cli.csv -NoTypeInformation
#get hash of running processes#
foreach ($proc in Get-Process | select path) {Get-FileHash $proc.path -Algorithm sha256 | Export-Csv -Append -Path .\$HN-process-hash.csv -NoTypeInformation}
Write-host "Gathering Scheduled Task Info"
#get scheduled task info#
schtasks /query /FO CSV /v | convertfrom-csv | where { $_.TaskName -ne "TaskName" } | select "TaskName","Run As User", Author, "Task to Run"| Export-Csv -Path .\$HN-schd-tasks.csv -NoTypeInformation
#get prefetch so we can have rough history of exes run on the system#
Write-host "Gathering Prefect Info"
Get-ChildItem C:\Windows\Prefetch | Select Name,LastWriteTime | Export-Csv -Path .\$HN-prefetch.csv -NoTypeInformation
#get persistence using persistence sniper#
Write-host "Gathering Persistence Info"
Import-Module .\PersistenceSniper.psd1
Find-AllPersistence | Export-Csv -Path .\$HN-persistence.csv -NoTypeInformation
#get event logs#
Write-host "Gathering Logs"
get-childitem C:\Windows\System32\winevt\Logs | where-object {$_.length -gt 69632} | Select -ExpandProperty FullName | Copy-Item -Destination .\logs\
Write-host "Forensic Recon Complete"
