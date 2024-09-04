# This script gets you the following info for each partition:
                                      # Free/Used Disk space
                                      # Top 10 files by size (exculdes .sys files and /windows/
# Recurse depth is set to 3 to avoid longer runs
# Gets total/used space for each partition in GB (internal and external drives)
$partitions = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 -or $_.DriveType -eq 2 }
foreach ($partition in $partitions) {
  $size = "{0:N2}" -f ($partition.Size/1GB)
  $freespace = "{0:N2}" -f ($partition.FreeSpace/1GB)
  $usedspace = "{0:N2}" -f ($size - $freespace)
Write-Host "==================================="
  Write-Host "Partition: $($partition.DeviceID)"
  Write-Host "Total size: $size GB"
  Write-Host "Free space: $freespace GB"
  Write-Host "Used space: $usedspace GB"
  Write-Host "Top 10 larest files:"

  # Gets the 20 largest files, excluding /Windows/ directory and .sys files
  Get-ChildItem "$($partition.DeviceID)\" -Recurse -Depth 3 -ErrorAction SilentlyContinue |
  Where-Object { 
    $_.FullName -notlike "*\Windows\*" -and 
    $_.Extension -ne ".sys" 
} |
    Sort-Object Length -Descending |
    Select-Object -First 10 |
    Format-Table FullName, @{Label="Size (GB)"; Expression={("{0:N2}" -f ($_.Length/1GB))}} -Wrap

  Write-Host "==================================="
}

