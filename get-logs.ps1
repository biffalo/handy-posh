#gathers logs from an endpoint and puts them in a folder you define in line 2#
$logpath = "C:\ktemp"
Copy-item C:\Windows\System32\winevt\Logs\Application.evtx -destination $logpath\Application.evtx
Copy-item C:\Windows\System32\winevt\Logs\Microsoft-Windows-Sysmon%4Operational.evtx -destination $logpath\Sysmon.evtx
Copy-item C:\Windows\System32\winevt\Logs\System.evtx -destination $logpath\System.evtx
Copy-item C:\Windows\System32\winevt\Logs\Security.evtx -destination $logpath\Security.evtx
Copy-item C:\Windows\System32\winevt\Logs\Microsoft-Windows-PowerShell%4Operational.evtx -destination $logpath\Powershell.evtx
Copy-item "C:\Windows\System32\winevt\Logs\Microsoft-Windows-Windows Defender%4Operational.evtx" -destination $logpath\Defender.evtx
Copy-item C:\windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx -destination $logpath\TSconnections.evtx
Copy-item C:\windows\System32\winevt\Logs\Microsoft-Windows-WinRM%4Operational.evtx -destination $logpath\Winrm.evtx
Copy-item C:\windows\System32\winevt\Logs\Microsoft-Windows-Shell-Core%4Operational.evtx -destination $logpath\Poshcore.evtx
Copy-item C:\windows\System32\winevt\Logs\Microsoft-Windows-Bits-Client%4Operational.evtx -destination $logpath\Bits.evtx
Copy-item C:\windows\System32\winevt\Logs\Microsoft-Windows-Bits-Client%4Operational.evtx -destination $logpath\Bits.evtx
Copy-item C:\Windows\System32\winevt\Logs\Microsoft-Windows-TaskScheduler%4Operational.evtx -destination $logpath\TaskSchd.evtx