#gets total/used space for each partition in GB#
$partitions = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}
foreach ($partition in $partitions) {
  $size = "{0:N2}" -f ($partition.Size/1GB)
  $freespace = "{0:N2}" -f ($partition.FreeSpace/1GB)
  $usedspace = "{0:N2}" -f ($size - $freespace)
  Write-Host "Partition: $($partition.DeviceID)"
  Write-Host "Total size: $size GB"
  Write-Host "Free space: $freespace GB"
  Write-Host "Used space: $usedspace GB"
  #gets the 20 largest files in GB searching in C:\users\ recursivly#
  Get-ChildItem "C:\Users" -Recurse |
    Sort-Object Length -Descending |
    Select-Object -First 20 |
    Format-Table Name, @{Label="Size (GB)"; Expression={("{0:N2}" -f ($_.Length/1GB))}} -Wrap
  
  Write-Host
}
Write-Host "===================================="
Write-Host "20 largest files full path"
Get-ChildItem "C:\Users" -Recurse | Sort-Object Length -Descending | Select-Object -First 20 | Format-Table FullName -Wrap
