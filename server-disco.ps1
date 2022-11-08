#collects the following info and prints to $computername-info.txt // smb shares // installed features/roles // current network connections by process // installed apps
$sn = $env:COMPUTERNAME
Get-SMBShare >> $sn-info.txt
Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} >> $sn-info.txt
Get-NetTCPConnection | select LocalAddress,localport,remoteaddress,remoteport,state,@{name="process";Expression={(get-process -id $_.OwningProcess).ProcessName}}, @{Name="cmdline";Expression={(Get-WmiObject Win32_Process -filter "ProcessId = $($_.OwningProcess)").commandline}} | sort Remoteaddress -Descending | ft -wrap -autosize >> $sn-info.txt
Get-WMIObject -Query "SELECT * FROM Win32_Product" | Where Name -notlike "*Language*" | Select Name | Sort Name >> $sn-info.txt